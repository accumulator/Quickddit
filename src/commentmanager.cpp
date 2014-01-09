#include "commentmanager.h"

#include <QtNetwork/QNetworkReply>

#include "commentmodel.h"
#include "parser.h"

CommentManager::CommentManager(QObject *parent) :
    AbstractManager(parent), m_model(0), m_reply(0)
{
}

CommentModel *CommentManager::model() const
{
    return m_model;
}

void CommentManager::setModel(CommentModel *model)
{
    m_model = model;
}

void CommentManager::addComment(const QString &replyTofullname, const QString &rawText)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", replyTofullname);
    m_replyToFullname = replyTofullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/comment", parameters);
}

void CommentManager::onNetworkReplyReceived(QNetworkReply *reply)
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

void CommentManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        const CommentObject comment = Parser::parseNewComment(m_reply->readAll());
        m_model->insertComment(comment, m_replyToFullname);
    } else {
        emit error(m_reply->errorString());
    }

    setBusy(false);
    m_reply->deleteLater();
    m_reply = 0;
}

void CommentManager::abortActiveReply()
{
    if (m_reply != 0) {
        qWarning("CommentManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
}
