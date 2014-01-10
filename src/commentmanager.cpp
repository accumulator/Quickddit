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
    m_action = Insert;
    m_fullname = replyTofullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/comment", parameters);
}

void CommentManager::editComment(const QString &fullname, const QString &rawText)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", fullname);
    m_action = Edit;
    m_fullname = fullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/editusertext", parameters);
}

void CommentManager::deleteComment(const QString &fullname)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_action = Delete;
    m_fullname = fullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/del", parameters);
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
        switch (m_action) {
        case Insert:
            m_model->insertComment(Parser::parseNewComment(m_reply->readAll()), m_fullname);
            break;
        case Edit:
            m_model->editComment(Parser::parseNewComment(m_reply->readAll()));
            break;
        case Delete:
            m_model->deleteComment(m_fullname);
            break;
        }
    } else {
        emit error(m_reply->errorString());
    }

    m_fullname.clear();
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
