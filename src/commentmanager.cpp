#include "commentmanager.h"

#include <QtNetwork/QNetworkReply>

#include "commentmodel.h"
#include "parser.h"

CommentManager::CommentManager(QObject *parent) :
    AbstractManager(parent), m_model(new CommentModel(this)), m_sort(ConfidenceSort), m_reply(0)
{
}

CommentModel *CommentManager::model() const
{
    return m_model;
}

QString CommentManager::permalink() const
{
    return m_permalink;
}

void CommentManager::setPermalink(const QString &permalink)
{
    if (m_permalink != permalink) {
        m_permalink = permalink;
        emit permalinkChanged();
    }
}

CommentManager::SortType CommentManager::sort() const
{
    return m_sort;
}

void CommentManager::setSort(CommentManager::SortType sort)
{
    if (m_sort != sort) {
        m_sort = sort;
        emit sortChanged();
    }
}

void CommentManager::refresh()
{
    Q_ASSERT(!m_permalink.isEmpty());

    if (m_reply != 0) {
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    if (m_model->count() > 0)
        m_model->clear();

    QHash<QString, QString> parameters;
    parameters["sort"] = getSortString(m_sort);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditGetRequest(m_permalink, parameters);

    setBusy(true);
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
    if (m_reply->error() == QNetworkReply::NoError)
        m_model->append(Parser::parseCommentList(m_reply->readAll()));
    else
        emit error(m_reply->errorString());

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}

QString CommentManager::getSortString(SortType sort)
{
    switch (sort) {
    default: case ConfidenceSort: return "confidence";
    case TopSort: return "top";
    case NewSort: return "new";
    case HotSort: return "hot";
    case ControversialSort: return "controversial";
    case OldSort: return "old";
    }
}
