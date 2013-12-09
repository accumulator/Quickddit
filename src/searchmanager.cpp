#include "searchmanager.h"

#include <QtNetwork/QNetworkReply>

#include "linkmodel.h"
#include "parser.h"

SearchManager::SearchManager(QObject *parent) :
    AbstractManager(parent), m_model(new LinkModel(this)), m_reply(0)
{
}

LinkModel *SearchManager::model() const
{
    return m_model;
}

QString SearchManager::query() const
{
    return m_query;
}

void SearchManager::setQuery(const QString &query)
{
    if (m_query != query) {
        m_query = query;
        emit queryChanged();
    }
}

void SearchManager::refresh(bool refreshOlder)
{
    Q_ASSERT(!m_query.isEmpty());

    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    if (refreshOlder && m_model->count() == 0)
        refreshOlder = false;
    else if (!refreshOlder && m_model->count() > 0)
        m_model->clear();

    QHash<QString,QString> parameters;
    parameters["q"] = m_query;
    if (refreshOlder)
        parameters["after"] = m_model->lastFullname();

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditGetRequest("/search", parameters);

    setBusy(true);
}

void SearchManager::onNetworkReplyReceived(QNetworkReply *reply)
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

void SearchManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError)
        m_model->append(Parser::parseLinkList(m_reply->readAll()));
    else
        emit error(m_reply->errorString());

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}
