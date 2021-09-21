/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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
#include <QDebug>

#include "appsettings.h"
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
    map["previewUrl"] = link.previewUrl();
    map["previewHeight"] = link.previewHeight();
    map["previewWidth"] = link.previewWidth();
    map["text"] = link.text();
    map["rawText"] = link.rawText();
    map["permalink"] = link.permalink();
    map["url"] = link.url();
    map["isSticky"] = link.isSticky();
    map["isNSFW"] = link.isNSFW();
    map["flairText"] = link.flairText();
    map["isSelfPost"] = link.isSelfPost();
    map["isArchived"] = link.isArchived();
    map["gilded"] = link.gilded();
    map["saved"] = link.saved();
    map["isLocked"] = link.isLocked();
    map["crossposts"] = link.crossposts();

    return map;
}

LinkModel::LinkModel(QObject *parent) :
    AbstractListModelManager(parent), m_location(FrontPage), m_section(UndefinedSection), m_sectionTimeRange(AllTime),
    m_searchSort(RelevanceSort), m_searchTimeRange(AllTime)
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
    case PreviewUrlRole: return link.previewUrl();
    case PreviewHeightRole: return link.previewHeight();
    case PreviewWidthRole: return link.previewWidth();
    case TextRole: return link.text();
    case RawTextRole: return link.rawText();
    case PermalinkRole: return link.permalink();
    case UrlRole: return link.url();
    case IsStickyRole: return link.isSticky();
    case IsNSFWRole: return link.isNSFW();
    case IsPromotedRole: return link.isPromoted();
    case FlairTextRole: return link.flairText();
    case IsSelfPostRole: return link.isSelfPost();
    case IsArchivedRole: return link.isArchived();
    case GildedRole: return link.gilded();
    case IsSavedRole: return link.saved();
    case IsLockedRole: return link.isLocked();
    case CrosspostsRole: return link.crossposts();

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

LinkModel::TimeRange LinkModel::sectionTimeRange() const
{
    return m_sectionTimeRange;
}

void LinkModel::setSectionTimeRange(LinkModel::TimeRange sectionTimeRange)
{
    if (m_sectionTimeRange != sectionTimeRange) {
        m_sectionTimeRange = sectionTimeRange;
        emit sectionTimeRangeChanged();
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

LinkModel::TimeRange LinkModel::searchTimeRange() const
{
    return m_searchTimeRange;
}

void LinkModel::setSearchTimeRange(LinkModel::TimeRange timeRange)
{
    if (m_searchTimeRange != timeRange) {
        m_searchTimeRange = timeRange;
        emit searchTimeRangeChanged();
    }
}

QString LinkModel::getRelativeUrl()
{
    QString relativeUrl;
    switch (m_location) {
    case FrontPage:
        relativeUrl += "";
        break;
    case All:
        relativeUrl += "/r/all";
        break;
    case Popular:
        relativeUrl += "/r/popular";
        break;
    case Subreddit:
        if (m_subreddit.isEmpty() || m_subreddit.compare("all", Qt::CaseInsensitive) == 0 || m_subreddit.compare("popular", Qt::CaseInsensitive) == 0)
            qWarning("LinkModel::refresh(): Set location to FrontPage, Popular or All instead");
        relativeUrl += "/r/" + m_subreddit;
        break;
    case Multireddit:
        relativeUrl += "/me/m/" + m_multireddit;
        break;
    case Search:
        if (!m_subreddit.isEmpty()) {
            relativeUrl += "/r/" + m_subreddit;
        }
        relativeUrl += "/search";
        break;
    case Duplicates:
        relativeUrl += "/duplicates/" + m_subreddit;
        break;
    }

    return relativeUrl;
}

void LinkModel::refresh(bool refreshOlder)
{
    QHash<QString,QString> parameters;
    parameters["limit"] = "50";
    QString relativeUrl = getRelativeUrl();

    if (m_section == UndefinedSection) {
        // set a default
        setSection(HotSection);

        QList<AppSettings::SubredditPrefs> srpl = manager()->settings()->subredditPrefs();
        for (int i = 0; i < srpl.count(); i++) {
            if (relativeUrl == srpl.at(i).relPath) {
                setSection((Section)srpl.at(i).section);
                setSectionTimeRange((TimeRange)srpl.at(i).sectionTimeRange);
                break;
            }
        }
    }

    if (m_sectionTimeRange != AllTime) {
        parameters["t"] = getTimeRangeString(m_sectionTimeRange);
    }

    if (m_location == Search) {
        parameters["q"] = m_searchQuery;
        parameters["sort"] = getSearchSortString(m_searchSort);
        parameters["t"] = getTimeRangeString(m_searchTimeRange);
        if (!m_subreddit.isEmpty()) {
            parameters["restrict_sr"] = "true";
        }
    } else {
        relativeUrl += "/" + getSectionString(m_section);
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

    doRequest(APIRequest::GET, relativeUrl, SLOT(onFinished(QNetworkReply*)), parameters);

    m_title = relativeUrl;
    if ( (m_section == LinkModel::TopSection || m_section == LinkModel::ControversialSection)
         && m_sectionTimeRange != AllTime )
        m_title += " (" + getTimeRangeString(m_sectionTimeRange).left(1) + ")";

    emit titleChanged();
}

void LinkModel::saveSubredditPrefs()
{
    QString relativeUrl = getRelativeUrl();
    QList<AppSettings::SubredditPrefs> subredditPrefsList = manager()->settings()->subredditPrefs();
    for (int i = 0; i < subredditPrefsList.count(); i++) {
        if (relativeUrl == subredditPrefsList.at(i).relPath) {
            subredditPrefsList[i].section = m_section;
            subredditPrefsList[i].sectionTimeRange = m_sectionTimeRange;
            manager()->settings()->setSubredditPrefs(subredditPrefsList);
            return;
        }
    }
    // not found
    AppSettings::SubredditPrefs newprefs;
    newprefs.relPath = relativeUrl;
    newprefs.section = m_section;
    newprefs.sectionTimeRange = m_sectionTimeRange;
    subredditPrefsList.append(newprefs);
    manager()->settings()->setSubredditPrefs(subredditPrefsList);
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

void LinkModel::changeSaved(const QString &fullname, bool saved)
{
    for (int i = 0; i < m_linkList.count(); ++i) {
        LinkObject link = m_linkList.at(i);

        if (link.fullname() == fullname) {
            link.setSaved(saved);
            emit dataChanged(index(i), index(i));
            break;
        }
    }
}

void LinkModel::editLink(const LinkObject &link)
{
    int editIndex = -1;

    for (int i = 0; i < m_linkList.count(); ++i) {
        if (m_linkList.at(i).fullname() == link.fullname()) {
            editIndex = i;
            break;
        }
    }

    if (editIndex == -1) {
        qWarning("LinkModel::editLink(): Unable to find the link");
        return;
    }

    m_linkList.replace(editIndex, link);
    emit dataChanged(index(editIndex), index(editIndex));
}

void LinkModel::deleteLink(const QString &fullname)
{
    int deleteIndex = -1;

    for (int i = 0; i < m_linkList.count(); ++i) {
        if (m_linkList.at(i).fullname() == fullname) {
            deleteIndex = i;
            break;
        }
    }

    if (deleteIndex == -1) {
        qWarning("LinkModel::deleteLink(): Unable to find the link");
        return;
    }

    beginRemoveRows(QModelIndex(), deleteIndex, deleteIndex);
    m_linkList.removeAt(deleteIndex);
    endRemoveRows();

    emit dataChanged(index(deleteIndex), index(deleteIndex));
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
    roles[PreviewUrlRole] = "previewUrl";
    roles[PreviewHeightRole] = "previewHeight";
    roles[PreviewWidthRole] = "previewWidth";
    roles[TextRole] = "text";
    roles[RawTextRole] = "rawText";
    roles[PermalinkRole] = "permalink";
    roles[UrlRole] = "url";
    roles[IsStickyRole] = "isSticky";
    roles[IsNSFWRole] = "isNSFW";
    roles[IsPromotedRole] = "isPromoted";
    roles[FlairTextRole] = "flairText";
    roles[IsSelfPostRole] = "isSelfPost";
    roles[IsArchivedRole] = "isArchived";
    roles[GildedRole] = "gilded";
    roles[IsSavedRole] = "saved";
    roles[IsLockedRole] = "isLocked";
    roles[CrosspostsRole] = "crossposts";
    return roles;
}

void LinkModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            Listing<LinkObject> links = m_location == Duplicates
                                        ? Parser::parseDuplicates(reply->readAll())
                                        : Parser::parseLinkList(reply->readAll());
            if (!links.isEmpty()) {
                // remove duplicate
                if (!m_linkList.isEmpty()) {
                    QMutableListIterator<LinkObject> i(links);
                    while (i.hasNext()) {
                        if (m_linkList.contains(i.next()))
                            i.remove();
                    }
                }
                // remove filtered
                if (m_location == All || m_location == Popular) {
                    QMutableListIterator<LinkObject> i(links);
                    QStringList filteredSubreddits = manager()->settings()->filteredSubreddits();
                    qDebug() << "filtered subreddits:" << filteredSubreddits;
                    while (i.hasNext()) {
                        if (filteredSubreddits.contains(i.next().subreddit(), Qt::CaseInsensitive))
                            i.remove();
                    }
                }

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
}

QString LinkModel::getSectionString(Section section)
{
    switch (section) {
    case BestSection: return "best";
    case HotSection: return "hot";
    case NewSection: return "new";
    case RisingSection: return "rising";
    case ControversialSection: return "controversial";
    case TopSection: return "top";
    case GildedSection: return "gilded";
    case UndefinedSection: return "";
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

QString LinkModel::getTimeRangeString(TimeRange timeRange)
{
    switch (timeRange) {
    case AllTime: return "all";
    case Hour: return "hour";
    case Day: return "day";
    case Week: return "week";
    case Month: return "month";
    case Year: return "year";
    default:
        qWarning("LinkModel::getTimeRangeString(): Invalid time range");
        return "";
    }
}
