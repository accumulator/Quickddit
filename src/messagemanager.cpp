#include "messagemanager.h"

#include <QtNetwork/QNetworkReply>

MessageManager::MessageManager(QObject *parent) :
    AbstractManager(parent), m_reply(0)
{
}

void MessageManager::reply(const QString &fullname, const QString &rawText)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", fullname);
    m_fullname = fullname;
    m_action = Reply;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/comment", parameters);
}

void MessageManager::markRead(const QString &fullname)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_fullname = fullname;
    m_action = MarkRead;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/read_message", parameters);
}

void MessageManager::markUnread(const QString &fullname)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_fullname = fullname;
    m_action = MarkUnread;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/unread_message", parameters);
}

void MessageManager::onNetworkReplyReceived(QNetworkReply *reply)
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

void MessageManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        switch (m_action) {
        case Reply: emit replySuccess(); break;
        case MarkRead: emit markReadStatusSuccess(m_fullname, false); break;
        case MarkUnread: emit markReadStatusSuccess(m_fullname, true); break;
        default: qFatal("MessageManager::onFinished(): Invalid m_action"); break;
        }
    } else {
        error(m_reply->errorString());
    }

    setBusy(false);
    m_reply->deleteLater();
    m_reply = 0;
}

void MessageManager::abortActiveReply()
{
    if (m_reply != 0) {
        qWarning("MessageManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
}
