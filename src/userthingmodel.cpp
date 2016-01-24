/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

#include <QtNetwork/QNetworkReply>

#include "userthingmodel.h"
#include "utils.h"
#include "appsettings.h"

UserThingModel::UserThingModel(QObject *parent) :
  AbstractListModelManager(parent), m_request(0)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
  setRoleNames(customRoleNames());
#endif
}

void UserThingModel::classBegin()
{
}

void UserThingModel::componentComplete()
{
    refresh(false);
}

int UserThingModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_commentList.count();
}

QVariant UserThingModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT_X(index.row() < m_commentList.count(), Q_FUNC_INFO, "index out of range");

    const CommentObject comment = m_commentList.at(index.row());

    switch (role) {
    case FullnameRole: return comment.fullname();
    case AuthorRole: {
        QString author = comment.author();
        if (comment.isSubmitter())
            author += " [S]";
        switch (comment.distinguished()) {
        case CommentObject::DistinguishedByModerator: author += " [M]"; break;
        case CommentObject::DistinguishedByAdmin: author += " [A]"; break;
        case CommentObject::DistinguishedBySpecial: author += " [?]"; break;
        default: break;
        }
        return author;
    }
    case BodyRole: return comment.body();
    case RawBodyRole: return comment.rawBody();
    case ScoreRole: return comment.score();
    case LikesRole: return comment.likes();
    case CreatedRole: {
        QString createdTimeDiff = Utils::getTimeDiff(comment.created());
        // TODO: show the edited time diff in UI
        if (comment.edited().isValid())
            createdTimeDiff.append("*");
        return createdTimeDiff;
    }
    case DepthRole: return comment.depth();
    case IsScoreHiddenRole: return comment.isScoreHidden();
    case IsValidRole: return comment.author() != "[deleted]";
    case IsAuthorRole: return comment.author() == manager()->settings()->redditUsername();
    case CollapsedRole: return (comment.isCollapsed());
    case SubredditRole: return comment.subreddit();
    case LinkTitleRole: return comment.linkTitle();
    case LinkIdRole: return comment.linkId();
    default:
        qCritical("UserThingModel::data(): Invalid role");
        return QVariant();
    }
}


QString UserThingModel::username() const
{
    return m_username;
}

void UserThingModel::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username= username;
        emit usernameChanged();
    }
}


QHash<int, QByteArray> UserThingModel::customRoleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FullnameRole] = "fullname";
    roles[AuthorRole] = "author";
    roles[BodyRole] = "body";
    roles[RawBodyRole] = "rawBody";
    roles[ScoreRole] = "score";
    roles[LikesRole] = "likes";
    roles[CreatedRole] = "created";
    roles[DepthRole] = "depth";
    roles[IsScoreHiddenRole] = "isScoreHidden";
    roles[IsValidRole] = "isValid";
    roles[IsAuthorRole] = "isAuthor";
    roles[CollapsedRole] = "isCollapsed";
    roles[SubredditRole] = "subreddit";
    roles[LinkTitleRole] = "linkTitle";
    roles[LinkIdRole] = "linkId";
    return roles;
}

void UserThingModel::refresh(bool refreshOlder)
{
    if (m_username == "")
        return;

    abortActiveReply();

    QHash<QString,QString> parameters;
    parameters["limit"] = "25";

    if (!m_commentList.isEmpty()) {
        if (refreshOlder) {
            parameters["count"] = QString::number(m_commentList.count());
            parameters["after"] = m_commentList.last().fullname();
        } else {
            beginRemoveRows(QModelIndex(), 0, m_commentList.count() - 1);
            m_commentList.clear();
            endRemoveRows();
        }
    }

    m_request = manager()->createRedditRequest(this, APIRequest::GET, "/user/" + m_username + "/overview", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void UserThingModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray result = reply->readAll();
            qDebug() << "user things :" << result;
            Listing<CommentObject> comments = Parser::parseUserThingList(result);

            if (!comments.isEmpty()) {
                beginInsertRows(QModelIndex(), m_commentList.count(), m_commentList.count() + comments.count() - 1);
                m_commentList.append(comments);
                endInsertRows();
                setCanLoadMore(comments.hasMore());
            } else {
                setCanLoadMore(false);
            }
        }
        else
            emit error(reply->errorString());
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void UserThingModel::abortActiveReply()
{
    if (m_request != 0) {
        qWarning("UserThingModel::request(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }
}
