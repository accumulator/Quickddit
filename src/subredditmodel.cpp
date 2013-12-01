#include "subredditmodel.h"

#include <QtCore/QUrl>

SubredditModel::SubredditModel(QObject *parent) :
    QAbstractListModel(parent)
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
    setRoleNames(roles);
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
    default:
        qCritical("SubredditModel::data(): Invalid role");
        return QVariant();
    }
}

int SubredditModel::count() const
{
    return m_subredditList.count();
}

QString SubredditModel::lastFullname() const
{
    Q_ASSERT(!m_subredditList.isEmpty());

    return m_subredditList.last().fullname();
}

void SubredditModel::append(const QList<SubredditObject> &subredditList)
{
    if (subredditList.isEmpty())
        return;

    beginInsertRows(QModelIndex(), m_subredditList.count(), m_subredditList.count() + subredditList.count() - 1);
    m_subredditList.append(subredditList);
    endInsertRows();
}

void SubredditModel::clear()
{
    if (m_subredditList.isEmpty())
        return;

    beginRemoveRows(QModelIndex(), 0, m_subredditList.count() - 1);
    m_subredditList.clear();
    endRemoveRows();
}
