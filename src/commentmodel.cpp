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

#include "commentmodel.h"

#include <QtCore/QDateTime>
#include <QtCore/QRegExp>
#include <QtNetwork/QNetworkReply>
#include <QStringList>
#include <QDebug>

#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
#include <QtCore/QUrlQuery>
#endif

#include "utils.h"
#include "parser.h"
#include "appsettings.h"
#include "linkmodel.h"

static QRegExp commentPermalinkRegExp("(/r/\\w+)?/comments/\\w+/\\w*/(\\w+/?)");

CommentModel::CommentModel(QObject *parent) :
    AbstractListModelManager(parent), m_link(0), m_sort(ConfidenceSort), m_commentPermalink(false), m_request(0)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
    setRoleNames(customRoleNames());
#endif
    setCanLoadMore(false);
}

void CommentModel::classBegin()
{
}

void CommentModel::componentComplete()
{
    Q_ASSERT(!m_permalink.isEmpty());
    refresh(false);
}

int CommentModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_commentList.count();
}

QHash<int, QByteArray> CommentModel::customRoleNames() const
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
    roles[MoreChildrenCountRole] = "moreChildrenCount";
    roles[IsMoreChildrenRole] = "isMoreChildren";
    roles[MoreChildrenRole] = "moreChildren";
    roles[CollapsedRole] = "isCollapsed";
    roles[IsSavedRole] = "isSaved";
    roles[IsArchivedRole] = "isArchived";
    roles[IsStickiedRole] = "isStickied";
    roles[GildedRole] = "gilded";
    roles[IsSavedRole] = "saved";

    return roles;
}

QVariant CommentModel::data(const QModelIndex &index, int role) const
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
    case MoreChildrenCountRole: return comment.moreChildrenCount();
    case IsMoreChildrenRole: return comment.isMoreChildren();
    case MoreChildrenRole: return QVariant(comment.moreChildren());
    case CollapsedRole: return (comment.isCollapsed());
    case IsArchivedRole: return (comment.isArchived());
    case IsStickiedRole: return (comment.isStickied());
    case GildedRole: return (comment.gilded());
    case IsSavedRole: return (comment.saved());
    default:
        qCritical("CommentModel::data(): Invalid role");
        return QVariant();
    }
}

QString CommentModel::getSortString(CommentModel::SortType sort)
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

QVariant CommentModel::link() const
{
    return m_link;
}

void CommentModel::setLink(const QVariant &link)
{
    if (m_link != link) {
        m_link = link;
        emit linkChanged();
    }
}

QString CommentModel::permalink() const
{
    return m_permalink;
}

void CommentModel::setPermalink(const QString &permalink)
{
    if (m_permalink != permalink) {
        m_permalink = permalink;
        emit permalinkChanged();

#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
        bool hasCommentQuery = QUrlQuery(QUrl(m_permalink)).hasQueryItem("comment");
#else
        bool hasCommentQuery = QUrl(m_permalink).hasQueryItem("comment");
#endif
        if (m_permalink.contains(commentPermalinkRegExp) || hasCommentQuery)
            setCommentPermalink(true);
    }
}

CommentModel::SortType CommentModel::sort() const
{
    return m_sort;
}

void CommentModel::setSort(CommentModel::SortType sort)
{
    if (m_sort != sort) {
        m_sort = sort;
        emit sortChanged();
    }
}

bool CommentModel::isCommentPermalink() const
{
    return m_commentPermalink;
}

void CommentModel::setCommentPermalink(bool commentPermalink)
{
    if (m_commentPermalink != commentPermalink) {
        m_commentPermalink = commentPermalink;
        emit commentPermalinkChanged();
    }
}

// model manipulation methods

void CommentModel::insertComment(CommentObject comment, const QString &replyToFullname)
{
    int insertIndex = 0;

    // if reply to is a comment, get the insert index and set the comment depth
    if (replyToFullname.startsWith("t1")) {
        for (int i = 0; i < m_commentList.count(); ++i) {
            if (m_commentList.at(i).fullname() == replyToFullname) {
                comment.setDepth(m_commentList.at(i).depth() + 1);
                insertIndex = i + 1;
                break;
            }
        }
    }

    beginInsertRows(QModelIndex(), insertIndex, insertIndex);
    m_commentList.insert(insertIndex, comment);
    endInsertRows();
}

void CommentModel::editComment(CommentObject comment)
{
    int editIndex = -1;

    for (int i = 0; i < m_commentList.count(); ++i) {
        if (m_commentList.at(i).fullname() == comment.fullname()) {
            editIndex = i;
            break;
        }
    }

    if (editIndex == -1) {
        qWarning("CommentModel::editComment(): Unable to find the comment");
        return;
    }

    comment.setDepth(m_commentList.at(editIndex).depth());
    m_commentList.replace(editIndex, comment);
    emit dataChanged(index(editIndex), index(editIndex));
}

void CommentModel::deleteComment(const QString &fullname)
{
    int deleteIndex = -1;

    for (int i = 0; i < m_commentList.count(); ++i) {
        if (m_commentList.at(i).fullname() == fullname) {
            deleteIndex = i;
            break;
        }
    }

    if (deleteIndex == -1) {
        qWarning("CommentModel::deleteComment(): Unable to find the comment");
        return;
    }

    beginRemoveRows(QModelIndex(), deleteIndex, deleteIndex);
    m_commentList.removeAt(deleteIndex);
    endRemoveRows();
}

int CommentModel::getParentIndex(int index) const
{
    int parentDepth = m_commentList.at(index).depth() - 1;
    for (int i = index; i >= 0; --i) {
        if (m_commentList.at(i).depth() == parentDepth)
            return i;
    }

    qWarning("CommentModel::getParentIndex(): Cannot find parent index");
    return index;
}

int CommentModel::getCommentIndex(const QString &comment)
{
    for (int i = 0; i < m_commentList.count(); ++i) {
        if (m_commentList.at(i).fullname() == comment) {
            return i;
        }
    }

    return -1;
}

void CommentModel::changeLinkLikes(const QString &fullname, int likes)
{
    if (!m_link.type() == QVariant::Map) {
        qWarning("CommentModel::changeLinkLikes(): link is not provided by CommentModel");
        return;
    }

    QVariantMap linkMap = m_link.toMap();

    if (linkMap.value("fullname").toString() != fullname) {
        return;
    }

    int oldLikes = linkMap.value("likes").toInt();
    linkMap["likes"] = likes;
    linkMap["score"] = linkMap["score"].toInt() + (likes - oldLikes);
    m_link = linkMap;
    emit linkChanged();
}

void CommentModel::changeLikes(const QString &fullname, int likes)
{
    for (int i = 0; i < m_commentList.count(); ++i) {
        CommentObject comment = m_commentList.at(i);

        if (comment.fullname() == fullname) {
            int oldLikes = comment.likes();
            comment.setLikes(likes);
            comment.setScore(comment.score() + (comment.likes() - oldLikes));
            emit dataChanged(index(i), index(i));
            break;
        }
    }
}

void CommentModel::collapse(int index)
{
    Q_ASSERT(index < m_commentList.count());

    QList<CommentObject> subtree;

    CommentObject first = m_commentList.at(index);
    int depth = first.depth();

    int itemIndex = index + 1;
    for (; itemIndex < m_commentList.count(); ++itemIndex) {
        if (m_commentList.at(itemIndex).depth() <= depth) {
            break;
        }
        qDebug() << "collapsing" << itemIndex << "at" << m_commentList.at(itemIndex).depth() << "from" << index << first.fullname() << "at" << depth;
        subtree.append(m_commentList.at(itemIndex)); // reparents?
    }
    itemIndex--;

    m_collapsedCommentLists.insert(first.fullname(), subtree);

    qDebug() << "trees" << m_collapsedCommentLists.size() << index << ".." << itemIndex;

    beginRemoveRows(QModelIndex(), index, itemIndex);
    for (int i = itemIndex; i >= index; i--) {
        qDebug() << "removing" << i;
        m_commentList.removeAt(i);
    }
    endRemoveRows();

    first.setIsCollapsed(true);
    first.setMoreChildrenCount(itemIndex - index + 1);

    beginInsertRows(QModelIndex(), index, index);
    m_commentList.insert(index, first);
    endInsertRows();
}

void CommentModel::expand(const QString &fullname)
{
    qDebug() << "expand" << fullname;
    QHash<QString, QList<CommentObject> >::const_iterator i = m_collapsedCommentLists.find(fullname);

    if (i == m_collapsedCommentLists.end()) {
        qDebug() << fullname << "not found";
        return;
    }

    QList<CommentObject> commentList = i.value();

    qDebug() << "found" << commentList.size() << "items in list";

    int itemIndex = -1;
    for (int i = 0; i < m_commentList.count(); ++i) {
        if (m_commentList.at(i).fullname() == fullname) {
            itemIndex = i;
            break;
        }
    }

    if (itemIndex == -1) {
        qWarning("CommentModel::expand(): Unable to find the comment");
        return;
    }

    CommentObject item = m_commentList.at(itemIndex);

    beginRemoveRows(QModelIndex(), itemIndex, itemIndex);
    m_commentList.removeAt(itemIndex);
    endRemoveRows();

    item.setIsCollapsed(false);

    beginInsertRows(QModelIndex(), itemIndex, itemIndex + commentList.size());
    m_commentList.insert(itemIndex++, item);
    for (int i=0; i < commentList.size(); i++) {
        m_commentList.insert(itemIndex + i, commentList.at(i));
    }
    endInsertRows();

    m_collapsedCommentLists.remove(fullname);
}

// network methods

void CommentModel::refresh(bool refreshOlder)
{
    Q_ASSERT(!m_permalink.isEmpty());
    Q_UNUSED(refreshOlder);

    if (m_request != 0) {
        qWarning("CommentModel::refresh(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }

    if (!m_commentList.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, m_commentList.count() - 1);
        m_commentList.clear();
        endRemoveRows();

        // clear side storage
        m_collapsedCommentLists.clear();
    }

    QHash<QString, QString> parameters;
    parameters["sort"] = getSortString(m_sort);

    QUrl permalinkUrl(m_permalink);
    if (permalinkUrl.hasQuery()) {
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
        QListIterator<QPair<QString, QString> > i(QUrlQuery(permalinkUrl).queryItems());
#else
        QListIterator<QPair<QString, QString> > i(permalinkUrl.queryItems());
#endif
        while (i.hasNext()) {
            const QPair<QString, QString> &query = i.next();
            if (!m_commentPermalink && query.first == "comment")
                continue;
            parameters.insert(query.first, query.second);
        }
    }

    QString relativeUrl = permalinkUrl.path();
    if (!m_commentPermalink && relativeUrl.contains(commentPermalinkRegExp))
        relativeUrl.remove(commentPermalinkRegExp.cap(2));

    m_request = manager()->createRedditRequest(this, APIRequest::GET, relativeUrl, parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void CommentModel::moreComments(int index, const QVariant &children)
{
    Q_ASSERT(!m_permalink.isEmpty());

    if (m_request != 0) {
        qWarning("CommentModel::moreComments(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }

    if (!m_link.type() == QVariant::Map) {
        qWarning("CommentModel::moreComments(): link is not provided by CommentModel");
        return;
    }

    m_index = index;
    m_depth = m_commentList.at(index).depth();

    QVariantMap linkMap = m_link.toMap();

    QHash<QString, QString> parameters;
    parameters["sort"] = getSortString(m_sort);
    parameters["link_id"] = linkMap.value("fullname").toString();
    parameters["children"] = children.toStringList().join(",");

    qDebug() << "more comments params:" << parameters;

    m_request = manager()->createRedditRequest(this, APIRequest::GET, "/api/morechildren", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onMoreCommentsFinished(QNetworkReply*)));

    setBusy(true);
}

void CommentModel::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const QPair< LinkObject, QList<CommentObject> > comments = Parser::parseCommentList(reply->readAll());
            m_link = LinkModel::toLinkVariantMap(comments.first);
            emit linkChanged();

            if (!m_commentList.isEmpty()) {
                beginRemoveRows(QModelIndex(), 0, m_commentList.count() - 1);
                m_commentList.clear();
                endRemoveRows();
            }
            if (!comments.second.isEmpty()) {
                beginInsertRows(QModelIndex(), m_commentList.count(), m_commentList.count() + comments.second.count() - 1);
                m_commentList.append(comments.second);
                endInsertRows();
            }
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
    emit commentLoaded();
}

void CommentModel::onMoreCommentsFinished(QNetworkReply *reply) {
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const QList<CommentObject> commentList = Parser::parseMoreChildren(reply->readAll(), m_link.toMap().value("author").toString(), m_depth);
            qDebug() << commentList.length() << "more comments received";
            int index = m_index;
            beginRemoveRows(QModelIndex(), m_index, m_index);
            m_commentList.removeAt(m_index);
            endRemoveRows();
            beginInsertRows(QModelIndex(), m_index, m_index + commentList.length() - 1);
            foreach(const CommentObject comment, commentList) {
                m_commentList.insert(index++, comment);
            }
            endInsertRows();
        } else {
            emit error(reply->errorString());
        }
    }
    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}
