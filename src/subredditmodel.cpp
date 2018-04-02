/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

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

#include "subredditmodel.h"

#include <QtCore/QUrl>
#include <QtNetwork/QNetworkReply>

#include "parser.h"

SubredditModel::SubredditModel(QObject *parent) :
    AbstractListModelManager(parent), m_section(PopularSection)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
    setRoleNames(customRoleNames());
#endif
}

void SubredditModel::classBegin()
{
}

void SubredditModel::componentComplete()
{
    if (m_section == SearchSection && m_query.isEmpty())
        return;
}

int SubredditModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_subredditList.count();
}

QVariant SubredditModel::data(const QModelIndex &index, int role) const
{
    const SubredditObject subreddit = m_subredditList.at(index.row());

    switch (role) {
    case FullnameRole: return subreddit.fullname();
    case DisplayNameRole: return subreddit.displayName();
    case UrlRole: return subreddit.url();
    case HeaderImageUrlRole: return subreddit.headerImageUrl();
    case ShortDescriptionRole: return subreddit.shortDescription();
    case LongDescriptionRole: return subreddit.longDescription();
    case SubscribersRole: return subreddit.subscribers();
    case ActiveUsersRole: return subreddit.activeUsers();
    case IsNSFWRole: return subreddit.isNSFW();
    case IsSubscribedRole: return subreddit.isSubscribed();
    case IsContributorRole: return subreddit.isContributor();
    case IsBannedRole: return subreddit.isBanned();
    case IsModeratorRole: return subreddit.isModerator();
    case IsMutedRole: return subreddit.isMuted();

    default:
        qCritical("SubredditModel::data(): Invalid role");
        return QVariant();
    }
}

SubredditModel::Section SubredditModel::section() const
{
    return m_section;
}

void SubredditModel::setSection(SubredditModel::Section section)
{
    if (m_section != section) {
        m_section = section;
        emit sectionChanged();
    }
}

QString SubredditModel::query() const
{
    return m_query;
}

void SubredditModel::setQuery(const QString &query)
{
    if (m_query != query) {
        m_query = query;
        emit queryChanged();
    }
}

void SubredditModel::refresh(bool refreshOlder)
{
    QString relativeUrl;
    QHash<QString, QString> parameters;
    parameters["limit"] = "50";

    switch (m_section) {
    case PopularSection:
        relativeUrl = "/subreddits/popular";
        break;
    case NewSection:
        relativeUrl = "/subreddits/new";
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
        break;
    }

    if (!m_subredditList.isEmpty()) {
        if (refreshOlder) {
            parameters["count"] = QString::number(m_subredditList.count());
            parameters["after"] = m_subredditList.last().fullname();
        } else {
            beginRemoveRows(QModelIndex(), 0, m_subredditList.count() - 1);
            m_subredditList.clear();
            endRemoveRows();
        }
    }

    doRequest(APIRequest::GET, relativeUrl, SLOT(onFinished(QNetworkReply*)), parameters);
}

void SubredditModel::clear()
{
    beginRemoveRows(QModelIndex(), 0, m_subredditList.count() - 1);
    m_subredditList.clear();
    endRemoveRows();
    setCanLoadMore(false);
}

QHash<int, QByteArray> SubredditModel::customRoleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FullnameRole] = "fullname";
    roles[DisplayNameRole] = "displayName";
    roles[UrlRole] = "url";
    roles[HeaderImageUrlRole] = "headerImageUrl";
    roles[ShortDescriptionRole] = "shortDescription";
    roles[LongDescriptionRole] = "longDescription";
    roles[SubscribersRole] = "subscribers";
    roles[ActiveUsersRole] = "activeUsers";
    roles[IsNSFWRole]= "isNSFW";
    roles[IsSubscribedRole] = "isSubscribed";
    roles[IsContributorRole] = "isContributor";
    roles[IsBannedRole] = "isBanned";
    roles[IsModeratorRole] = "isModerator";
    roles[IsMutedRole] = "isMuted";
    return roles;
}

void SubredditModel::deleteSubreddit(const QString &fullname)
{
    int deleteIndex = -1;

    for (int i = 0; i < m_subredditList.count(); ++i) {
        if (m_subredditList.at(i).fullname() == fullname) {
            deleteIndex = i;
            break;
        }
    }

    if (deleteIndex == -1) {
        qWarning("SubredditModel::deleteSubreddit: Unable to find the subreddit");
        return;
    }

    beginRemoveRows(QModelIndex(), deleteIndex, deleteIndex);
    m_subredditList.removeAt(deleteIndex);
    endRemoveRows();
}

void SubredditModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const Listing<SubredditObject> subreddits = Parser::parseSubredditList(reply->readAll());
            if (!subreddits.isEmpty()) {
                beginInsertRows(QModelIndex(), m_subredditList.count(),
                                m_subredditList.count() + subreddits.count() - 1);
                m_subredditList.append(subreddits);
                endInsertRows();
                setCanLoadMore(subreddits.hasMore());
            } else {
                setCanLoadMore(false);
            }
        } else {
            emit error(reply->errorString());
        }
    }
}
