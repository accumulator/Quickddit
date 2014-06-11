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

#include "linkmodel.h"

#include <QtCore/QDateTime>
#include <QtCore/QUrl>
#include <QtNetwork/QNetworkReply>

#include "utils.h"
#include "parser.h"

QVariantMap LinkModel::toLinkVariantMap(const LinkObject &link)
{
    QVariantMap map;
    map["fullname"] = link.fullname();
    switch (link.distinguished()) {
    case LinkObject::DistinguishedByModerator: map["author"] = link.author() + " [M]"; break;
    case LinkObject::DistinguishedByAdmin: map["author"] = link.author() + " [A]"; break;
    default: map["author"] = link.author(); break;
    }
    map["created"] = Utils::getTimeDiff(link.created());
    map["subreddit"] = link.subreddit();
    map["score"] = link.score();
    map["likes"] = link.likes();
    map["commentsCount"] = link.commentsCount();
    map["title"] = link.title();
    map["domain"] = link.domain();
    map["thumbnailUrl"] = link.thumbnailUrl();
    map["text"] = link.text();
    map["permalink"] = link.permalink();
    map["url"] = link.url();
    map["isSticky"] = link.isSticky();
    map["isNSFW"] = link.isNSFW();
    return map;
}

LinkModel::LinkModel(QObject *parent) :
    AbstractListModelManager(parent), m_location(FrontPage), m_section(HotSection), m_searchSort(RelevanceSort),
    m_searchTimeRange(AllTime), m_request(0)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
    setRoleNames(customRoleNames());
#endif
}

void LinkModel::classBegin()
{
}

void LinkModel::componentComplete()
{
    if (m_location == Search && m_searchQuery.isEmpty())
        return;

    refresh(false);
}

int LinkModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_linkList.count();
}

QVariant LinkModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT_X(index.row() < m_linkList.count(), Q_FUNC_INFO, "index out of range");

    const LinkObject link = m_linkList.at(index.row());

    switch (role) {
    case FullnameRole: return link.fullname();
    case AuthorRole:
        switch (link.distinguished()) {
        case LinkObject::DistinguishedByModerator: return link.author() + " [M]";
        case LinkObject::DistinguishedByAdmin: return link.author() + " [A]";
        case LinkObject::DistinguishedBySpecial: return link.author() + " [?]";
        default: return link.author();
        }
    case CreatedRole: return Utils::getTimeDiff(link.created());
    case SubredditRole: return link.subreddit();
    case ScoreRole: return link.score();
    case LikesRole: return link.likes();
    case CommentsCountRole: return link.commentsCount();
    case TitleRole: return link.title();
    case DomainRole: return link.domain();
    case ThumbnailUrlRole: return link.thumbnailUrl();
    case TextRole: return link.text();
    case PermalinkRole: return link.permalink();
    case UrlRole: return link.url();
    case IsStickyRole: return link.isSticky();
    case IsNSFWRole: return link.isNSFW();
    case IsPromotedRole: return link.isPromoted();
    default:
        qCritical("LinkModel::data(): Invalid role");
        return QVariant();
    }
}

QString LinkModel::title() const
{
    return m_title;
}

LinkModel::Location LinkModel::location() const
{
    return m_location;
}

void LinkModel::setLocation(LinkModel::Location location)
{
    if (m_location != location) {
        m_location = location;
        emit locationChanged();
    }
}

LinkModel::Section LinkModel::section() const
{
    return m_section;
}

void LinkModel::setSection(LinkModel::Section section)
{
    if (m_section != section) {
        m_section = section;
        emit sectionChanged();
    }
}

QString LinkModel::subreddit() const
{
    return m_subreddit;
}

void LinkModel::setSubreddit(const QString &subreddit)
{
    if (m_subreddit != subreddit) {
        m_subreddit = subreddit;
        emit subredditChanged();
    }
}

QString LinkModel::multireddit() const
{
    return m_multireddit;
}

void LinkModel::setMultireddit(const QString &multireddit)
{
    if (m_multireddit != multireddit) {
        m_multireddit = multireddit;
        emit multiredditChanged();
    }
}

QString LinkModel::searchQuery() const
{
    return m_searchQuery;
}

void LinkModel::setSearchQuery(const QString &query)
{
    if (m_searchQuery != query) {
        m_searchQuery = query;
        emit searchQueryChanged();
    }
}

LinkModel::SearchSortType LinkModel::searchSort() const
{
    return m_searchSort;
}

void LinkModel::setSearchSort(LinkModel::SearchSortType sort)
{
    if (m_searchSort != sort) {
        m_searchSort = sort;
        emit searchSortChanged();
    }
}

LinkModel::SearchTimeRange LinkModel::searchTimeRange() const
{
    return m_searchTimeRange;
}

void LinkModel::setSearchTimeRange(LinkModel::SearchTimeRange timeRange)
{
    if (m_searchTimeRange != timeRange) {
        m_searchTimeRange = timeRange;
        emit  searchTimeRangeChanged();
    }
}

void LinkModel::refresh(bool refreshOlder)
{
    if (m_request != 0) {
        qWarning("LinkModel::refresh(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }

    QString relativeUrl;
    QHash<QString,QString> parameters;
    parameters["limit"] = "50";

    switch (m_location) {
    case FrontPage:
        relativeUrl += "/" + getSectionString(m_section);
        break;
    case All:
        relativeUrl += "/r/all/" + getSectionString(m_section);
        break;
    case Subreddit:
        if (m_subreddit.isEmpty() || m_subreddit.compare("all", Qt::CaseInsensitive) == 0)
            qWarning("LinkModel::refresh(): Set location to FrontPage or All instead");
        relativeUrl += "/r/" + m_subreddit + "/" + getSectionString(m_section);
        break;
    case Multireddit:
        relativeUrl += "/me/m/" + m_multireddit + "/" + getSectionString(m_section);
        break;
    case Search:
        parameters["q"] = m_searchQuery;
        parameters["sort"] = getSearchSortString(m_searchSort);
        parameters["t"] = getSearchTimeRangeString(m_searchTimeRange);
        if (!m_subreddit.isEmpty()) {
            relativeUrl += "/r/" + m_subreddit;
            parameters["restrict_sr"] = "true";
        }
        relativeUrl += "/search";
    }

    if (!m_linkList.isEmpty()) {
        if (refreshOlder) {
            parameters["count"] = QString::number(m_linkList.count());
            parameters["after"] = m_linkList.last().fullname();
        } else {
            beginRemoveRows(QModelIndex(), 0, m_linkList.count() - 1);
            m_linkList.clear();
            endRemoveRows();
        }
    }


    m_request = manager()->createRedditRequest(this, APIRequest::GET, relativeUrl, parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    m_title = relativeUrl;
    emit titleChanged();
    setBusy(true);
}

void LinkModel::changeLikes(const QString &fullname, int likes)
{
    for (int i = 0; i < m_linkList.count(); ++i) {
        LinkObject link = m_linkList.at(i);

        if (link.fullname() == fullname) {
            int oldLikes = link.likes();
            link.setLikes(likes);
            link.setScore(link.score() + (link.likes() - oldLikes));
            emit dataChanged(index(i), index(i));
            break;
        }
    }
}

QHash<int, QByteArray> LinkModel::customRoleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FullnameRole] = "fullname";
    roles[AuthorRole] = "author";
    roles[CreatedRole] = "created";
    roles[SubredditRole] = "subreddit";
    roles[ScoreRole] = "score";
    roles[LikesRole] = "likes";
    roles[CommentsCountRole] = "commentsCount";
    roles[TitleRole] = "title";
    roles[DomainRole] = "domain";
    roles[ThumbnailUrlRole] = "thumbnailUrl";
    roles[TextRole] = "text";
    roles[PermalinkRole] = "permalink";
    roles[UrlRole] = "url";
    roles[IsStickyRole] = "isSticky";
    roles[IsNSFWRole] = "isNSFW";
    roles[IsPromotedRole] = "isPromoted";
    return roles;
}

void LinkModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const Listing<LinkObject> links = Parser::parseLinkList(reply->readAll());
            if (!links.isEmpty()) {
                beginInsertRows(QModelIndex(), m_linkList.count(), m_linkList.count() + links.count() - 1);
                m_linkList.append(links);
                endInsertRows();
                setCanLoadMore(links.hasMore());
            } else {
                setCanLoadMore(false);
            }
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

QString LinkModel::getSectionString(Section section)
{
    switch (section) {
    case HotSection: return "hot";
    case NewSection: return "new";
    case RisingSection: return "rising";
    case ControversialSection: return "controversial";
    case TopSection: return "top";
    case PromotedSection: return "ads";
    default:
        qWarning("LinkModel::getSectionString(): Invalid section");
        return "";
    }
}

QString LinkModel::getSearchSortString(SearchSortType sort)
{
    switch (sort) {
    case RelevanceSort: return "relevance";
    case NewSort: return "new";
    case HotSort: return "hot";
    case TopSort: return "top";
    case CommentsSort: return "comments";
    default:
        qWarning("LinkModel::getSearchSortString(): Invalid sort");
        return "";
    }
}

QString LinkModel::getSearchTimeRangeString(SearchTimeRange timeRange)
{
    switch (timeRange) {
    case AllTime: return "all";
    case Hour: return "hour";
    case Day: return "day";
    case Week: return "week";
    case Month: return "month";
    case Year: return "year";
    default:
        qWarning("LinkModel::getSearchTimeRangeString(): Invalid time range");
        return "";
    }
}
