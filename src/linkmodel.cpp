#include "linkmodel.h"

#include <QtCore/QDateTime>
#include <QtCore/QUrl>

#include "utils.h"

LinkModel::LinkModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[FullnameRole] = "fullname";
    roles[AuthorRole] = "author";
    roles[CreatedRole] = "created";
    roles[SubredditRole] = "subreddit";
    roles[ScoreRole] = "score";
    roles[CommentsCountRole] = "commentsCount";
    roles[TitleRole] = "title";
    roles[DomainRole] = "domain";
    roles[ThumbnailUrlRole] = "thumbnailUrl";
    roles[TextRole] = "text";
    roles[PermalinkRole] = "permalink";
    roles[UrlRole] = "url";
    roles[IsStickyRole] = "isSticky";
    roles[IsNSFWRole] = "isNSFW";
    setRoleNames(roles);
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
    case CommentsCountRole: return link.commentsCount();
    case TitleRole: return link.title();
    case DomainRole: return link.domain();
    case ThumbnailUrlRole: return link.thumbnailUrl();
    case TextRole: return link.text();
    case PermalinkRole: return link.permalink();
    case UrlRole: return link.url();
    case IsStickyRole: return link.isSticky();
    case IsNSFWRole: return link.isNSFW();
    default:
        qCritical("LinkModel::data(): Invalid role");
        return QVariant();
    }
}

int LinkModel::count() const
{
    return m_linkList.count();
}

QString LinkModel::lastFullname() const
{
    Q_ASSERT(!m_linkList.isEmpty());

    return m_linkList.last().fullname();
}

void LinkModel::append(const QList<LinkObject> &linkList)
{
    if (linkList.isEmpty())
        return;

    beginInsertRows(QModelIndex(), m_linkList.count(), m_linkList.count() + linkList.count() - 1);
    m_linkList.append(linkList);
    endInsertRows();
}

void LinkModel::clear()
{
    if (m_linkList.isEmpty())
        return;

    beginRemoveRows(QModelIndex(), 0, m_linkList.count() - 1);
    m_linkList.clear();
    endRemoveRows();
}
