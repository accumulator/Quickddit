#include "commentmodel.h"

#include <QtCore/QDateTime>

#include "utils.h"

CommentModel::CommentModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[FullnameRole] = "fullname";
    roles[AuthorRole] = "author";
    roles[BodyRole] = "body";
    roles[ScoreRole] = "score";
    roles[CreatedRole] = "created";
    roles[DepthRole] = "depth";
    roles[IsScoreHiddenRole] = "isScoreHidden";
    setRoleNames(roles);
}

int CommentModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_commentList.count();
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
    case ScoreRole: return comment.score();
    case CreatedRole: {
        QString createdTimeDiff = Utils::getTimeDiff(comment.created());
        // TODO: show the edited time diff in UI
        if (comment.edited().isValid())
            createdTimeDiff.append("*");
        return createdTimeDiff;
    }
    case DepthRole: return comment.depth();
    case IsScoreHiddenRole: return comment.isScoreHidden();
    default:
        qCritical("CommentModel::data(): Invalid role");
        return QVariant();
    }
}

int CommentModel::count() const
{
    return m_commentList.count();
}

QString CommentModel::lastFullName() const
{
    Q_ASSERT(!m_commentList.isEmpty());
    return m_commentList.last().fullname();
}

void CommentModel::append(const QList<CommentObject> &commentList)
{
    if (commentList.isEmpty())
        return;

    beginInsertRows(QModelIndex(), m_commentList.count(), m_commentList.count() + commentList.count() - 1);
    m_commentList.append(commentList);
    endInsertRows();
}

void CommentModel::clear()
{
    if (m_commentList.isEmpty())
        return;

    beginRemoveRows(QModelIndex(), 0, m_commentList.count() - 1);
    m_commentList.clear();
    endRemoveRows();
}
