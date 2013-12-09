#include "subredditmanager.h"

#include <QtNetwork/QNetworkReply>

#include "subredditmodel.h"
#include "parser.h"

SubredditManager::SubredditManager(QObject *parent) :
    AbstractManager(parent), m_model(new SubredditModel(this)), m_section(PopularSection), m_reply(0)
{
}

SubredditModel *SubredditManager::model() const
{
    return m_model;
}

SubredditManager::Section SubredditManager::section() const
{
    return m_section;
}

void SubredditManager::setSection(Section section)
{
    if (m_section != section) {
        m_section = section;
        emit sectionChanged();
    }
}

QString SubredditManager::query() const
{
    return m_query;
}

void SubredditManager::setQuery(const QString &query)
{
    if (m_query != query) {
        m_query = query;
        emit queryChanged();
    }
}

void SubredditManager::refresh(bool refreshOlder)
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QString relativeUrl;
    QHash<QString, QString> parameters;
    bool oauth = true;

    switch (m_section) {
    case PopularSection:
        relativeUrl = "/subreddits/popular";
        oauth = false;
        break;
    case NewSection:
        relativeUrl = "/subreddits/new";
        oauth = false;
        break;
    case UserAsSubscriberSection:
        relativeUrl = "/subreddits/mine/subscriber";
        break;
    case UserAsContributorSection:
        relativeUrl = "/subreddits/mine/contributor";
        break;
    case UserAsModeratorSection:
        relativeUrl = "/subreddits/mine/moderator";
        break;
    case SearchSection:
        Q_ASSERT_X(!m_query.isEmpty(), Q_FUNC_INFO, "query is empty");
        relativeUrl = "/subreddits/search";
        parameters["q"] = m_query;
        oauth = false;
        break;
    }

    if (refreshOlder && m_model->count() > 0)
        parameters["after"] = m_model->lastFullname();
    else if (!refreshOlder)
        m_model->clear();

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditGetRequest(relativeUrl, parameters, oauth);

    setBusy(true);
}

void SubredditManager::onNetworkReplyReceived(QNetworkReply *reply)
{
    disconnect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
               this, SLOT(onNetworkReplyReceived(QNetworkReply*)));
    if (reply != 0) {
        m_reply = reply;
        m_reply->setParent(this);
        connect(m_reply, SIGNAL(finished()), SLOT(onFinished()));
    } else {
        setBusy(false);
    }
}

void SubredditManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError)
        m_model->append(Parser::parseSubredditList(m_reply->readAll()));
    else
        emit error(m_reply->errorString());

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}
