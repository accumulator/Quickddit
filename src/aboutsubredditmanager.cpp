#include "aboutsubredditmanager.h"

#include <QtNetwork/QNetworkReply>

#include "parser.h"

AboutSubredditManager::AboutSubredditManager(QObject *parent) :
    AbstractManager(parent), m_reply(0)
{
}

QString AboutSubredditManager::displayName() const
{
    return m_subredditObject.displayName();
}

QString AboutSubredditManager::url() const
{
    return m_subredditObject.url();
}

QUrl AboutSubredditManager::headerImageUrl() const
{
    return m_subredditObject.headerImageUrl();
}

QString AboutSubredditManager::shortDescription() const
{
    return m_subredditObject.shortDescription();
}

QString AboutSubredditManager::longDescription() const
{
    return m_subredditObject.longDescription();
}

int AboutSubredditManager::subscribers() const
{
    return m_subredditObject.subscribers();
}

int AboutSubredditManager::activeUsers() const
{
    return m_subredditObject.activeUsers();
}

bool AboutSubredditManager::isNSFW() const
{
    return m_subredditObject.isNSFW();
}

bool AboutSubredditManager::isSubscribed() const
{
    return m_subredditObject.isSubscribed();
}

void AboutSubredditManager::refresh(const QString &subreddit)
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QString relativeUrl = "/r/" + subreddit + "/about";

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::GET, relativeUrl);

    setBusy(true);
}

void AboutSubredditManager::subscribeOrUnsubscribe()
{
    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QHash<QString, QString> parameters;
    parameters["sr"] = m_subredditObject.fullname();
    if (m_subredditObject.isSubscribed())
        parameters["action"] = "unsub";
    else
        parameters["action"] = "sub";

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onSubscribeNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/subscribe", parameters);

    setBusy(true);
}

void AboutSubredditManager::onNetworkReplyReceived(QNetworkReply *reply)
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

void AboutSubredditManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        m_subredditObject = Parser::parseSubreddit(m_reply->readAll());
        emit dataChanged();
    } else {
        emit error(m_reply->errorString());
    }

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}

void AboutSubredditManager::onSubscribeNetworkReplyReceived(QNetworkReply *reply)
{
    disconnect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
               this, SLOT(onSubscribeNetworkReplyReceived(QNetworkReply*)));
    if (reply != 0) {
        m_reply = reply;
        m_reply->setParent(this);
        connect(m_reply, SIGNAL(finished()), SLOT(onSubscribeFinished()));
    } else {
        setBusy(false);
    }
}

void AboutSubredditManager::onSubscribeFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        m_subredditObject.setSubscribed(!m_subredditObject.isSubscribed());
        emit dataChanged();
        emit subscribeSuccess();
    } else {
        emit error(m_reply->errorString());
    }

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}
