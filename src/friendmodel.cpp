/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2017  Sander van Grieken

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

#include "utils.h"
#include "friendmodel.h"

FriendModel::FriendModel(QObject *parent):
    AbstractListModelManager(parent)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
  setRoleNames(customRoleNames());
#endif
}

FriendModel::~FriendModel()
{
    //
}

void FriendModel::classBegin()
{
}

void FriendModel::componentComplete()
{
    //refresh(false);
}

int FriendModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_friendList.count();
}

QHash<int, QByteArray> FriendModel::customRoleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[CommentRole] = "comment";

    return roles;
}

QVariant FriendModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT_X(index.row() < m_friendList.count(), Q_FUNC_INFO, "index out of range");

    const FriendObject friendObject = m_friendList.at(index.row());

    switch (role) {
    case FullnameRole: return QVariant(friendObject.fullname());
    case NameRole: return QVariant(friendObject.name());
    case CommentRole: return QVariant(friendObject.comment());
    case DateRole: return Utils::getTimeDiff(friendObject.date());

    default:
        qCritical("FriendModel::data(): Invalid role");
        return QVariant();
    }
}

void FriendModel::refresh(bool refreshOlder)
{
    QHash<QString,QString> parameters;
    parameters["limit"] = "25";

    if (!m_friendList.isEmpty()) {
        if (refreshOlder) {
            FriendObject fo = m_friendList.last();
            parameters["count"] = QString::number(m_friendList.count());
            parameters["after"] = fo.name();
        } else {
            beginRemoveRows(QModelIndex(), 0, m_friendList.count() - 1);
            m_friendList.clear();
            endRemoveRows();
        }
    }

    doRequest(APIRequest::GET, "/api/v1/me/friends", SLOT(onFinished(QNetworkReply*)), parameters);
}

void FriendModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            Listing<FriendObject> friends = Parser::parseFriendList(reply->readAll());

            if (!friends.isEmpty()) {
                beginInsertRows(QModelIndex(), m_friendList.count(), m_friendList.count() + friends.count() - 1);
                m_friendList.append(friends);
                endInsertRows();
                setCanLoadMore(friends.hasMore());
            } else {
                setCanLoadMore(false);
            }
        }
        else
            emit error(reply->errorString());
    }
}
