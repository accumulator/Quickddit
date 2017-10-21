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
#include <QDebug>

#include "userthingmodel.h"
#include "utils.h"
#include "appsettings.h"

UserThingModel::UserThingModel(QObject *parent) :
  AbstractListModelManager(parent), m_section(OverviewSection)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
  setRoleNames(customRoleNames());
#endif
}

UserThingModel::~UserThingModel()
{
    clearThingList();
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
    return m_thingList.count();
}

QHash<int, QByteArray> UserThingModel::customRoleNames() const
{
    QHash<int, QByteArray> roles;
    roles[KindRole] = "kind";
    roles[CommentRole] = "comment";
    roles[LinkRole] = "link";

    return roles;
}

QVariant UserThingModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT_X(index.row() < m_thingList.count(), Q_FUNC_INFO, "index out of range");

    const Thing* thing = m_thingList.at(index.row());

    switch (role) {
    case KindRole: return QVariant(thing->kind());
    case CommentRole: return commentData(dynamic_cast<const CommentObject*>(thing));
    case LinkRole: return linkData(dynamic_cast<const LinkObject *>(thing));

    default:
        qCritical("UserThingModel::data(): Invalid role");
        return QVariant();
    }
}

QVariantMap UserThingModel::commentData(const CommentObject* o) const
{
    if (!o) {
        qDebug() << "comment problem!";
        return QVariantMap();
    }

    QVariantMap result;
    result.insert("fullname", QVariant(o->fullname()));
    result.insert("author", QVariant(o->author()));
    result.insert("body", QVariant(o->body()));
    result.insert("score", QVariant(o->score()));
    QString createdTimeDiff = Utils::getTimeDiff(o->created());
    if (o->edited().isValid())
        createdTimeDiff.append("*");
    result.insert("created", QVariant(createdTimeDiff));
    result.insert("subreddit", QVariant(o->subreddit()));
    result.insert("linkTitle", QVariant(o->linkTitle()));
    result.insert("linkId", QVariant(o->linkId()));
    result.insert("saved", QVariant(o->saved()));
    result.insert("isStickied", QVariant(o->isStickied()));
    result.insert("gilded", QVariant(o->gilded()));

    return result;
}

QVariantMap UserThingModel::linkData(const LinkObject* o) const
{
    if (!o) {
        qDebug() << "link problem!";
        return QVariantMap();
    }

    QVariantMap result;
    result.insert("fullname", QVariant(o->fullname()));
    result.insert("author", QVariant(o->author()));
    result.insert("text", QVariant(o->text()));
    result.insert("score", QVariant(o->score()));
    result.insert("created", QVariant(Utils::getTimeDiff(o->created())));
    result.insert("subreddit", QVariant(o->subreddit()));
    result.insert("title", QVariant(o->title()));
    result.insert("isSelfPost", QVariant(o->isSelfPost()));
    result.insert("saved", QVariant(o->saved()));
    result.insert("flairText", QVariant(o->flairText()));
    result.insert("isSticky", QVariant(o->isSticky()));
    result.insert("isNSFW", QVariant(o->isNSFW()));
    result.insert("isPromoted", QVariant(o->isPromoted()));
    result.insert("gilded", QVariant(o->gilded()));
    result.insert("domain", QVariant(o->domain()));
    result.insert("thumbnailUrl", QVariant(o->thumbnailUrl()));
    result.insert("url", QVariant(o->url()));
    result.insert("isLocked", QVariant(o->isLocked()));
    result.insert("isArchived", QVariant(o->isArchived()));

    return result;
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

UserThingModel::Section UserThingModel::section() const
{
    return m_section;
}

void UserThingModel::setSection(UserThingModel::Section section)
{
    if (m_section != section) {
        m_section = section;
        emit sectionChanged();
    }
}

void UserThingModel::refresh(bool refreshOlder)
{
    if (m_username == "")
        return;

    QHash<QString,QString> parameters;
    parameters["limit"] = "25";

    if (!m_thingList.isEmpty()) {
        if (refreshOlder) {
            Thing* t = m_thingList.last();
            parameters["count"] = QString::number(m_thingList.count());
            parameters["after"] = t->fullname();
        } else {
            beginRemoveRows(QModelIndex(), 0, m_thingList.count() - 1);
            clearThingList();
            endRemoveRows();
        }
    }

    QString path = "/user/" + m_username;
    switch(m_section) {
    case OverviewSection : path += "/overview"; break;
    case CommentsSection : path += "/comments"; break;
    case SubmittedSection : path += "/submitted"; break;
    case UpvotedSection : path += "/upvoted"; break;
    case DownvotedSection : path += "/downvoted"; break;
    case SavedSection : path += "/saved"; break;
    default: qCritical("UserThingModel::refresh(): Invalid section"); break;
    }

    doRequest(APIRequest::GET, path, SLOT(onFinished(QNetworkReply*)), parameters);
}

void UserThingModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            Listing<Thing*> comments = Parser::parseUserThingList(reply->readAll());

            if (!comments.isEmpty()) {
                beginInsertRows(QModelIndex(), m_thingList.count(), m_thingList.count() + comments.count() - 1);
                m_thingList.append(comments);
                endInsertRows();
                setCanLoadMore(comments.hasMore());
            } else {
                setCanLoadMore(false);
            }
        }
        else
            emit error(reply->errorString());
    }
}

void UserThingModel::deleteThing(const QString &fullname)
{
    int deleteIndex = -1;
    qDebug() << "deleting thing from model";

    for (int i = 0; i < m_thingList.count(); ++i) {
        if (m_thingList.at(i)->fullname() == fullname) {
            deleteIndex = i;
            break;
        }
    }

    if (deleteIndex == -1) {
        qWarning("UserThingModel::deleteThing(): Unable to find the thing");
        return;
    }

    beginRemoveRows(QModelIndex(), deleteIndex, deleteIndex);
    m_thingList.removeAt(deleteIndex);
    endRemoveRows();
}

void UserThingModel::clearThingList()
{
    while(!m_thingList.isEmpty()) {
        delete m_thingList.takeLast();
    }
}
