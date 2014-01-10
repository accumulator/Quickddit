#include "commentmodel.h"

#include <QtCore/QDateTime>
#include <QtNetwork/QNetworkReply>

#include "utils.h"
#include "parser.h"
#include "appsettings.h"

CommentModel::CommentModel(QObject *parent) :
    AbstractListModelManager(parent), m_sort(ConfidenceSort), m_reply(0)
{
#if (QT_VERSION < QT_VERSION_CHECK(5, 0, 0))
    setRoleNames(customRoleNames());
#endif
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
    default:
        qCritical("CommentModel::data(): Invalid role");
        return QVariant();
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

void CommentModel::changeVote(const QString &fullname, VoteManager::VoteType voteType)
{
    for (int i = 0; i < m_commentList.count(); ++i) {
        CommentObject comment = m_commentList.at(i);

        if (comment.fullname() == fullname) {
            int oldLikes = comment.likes();
            switch (voteType) {
            case VoteManager::Upvote:
                comment.setLikes(1); break;
            case VoteManager::Downvote:
                comment.setLikes(-1); break;
            case VoteManager::Unvote:
                comment.setLikes(0); break;
            }
            comment.setScore(comment.score() + (comment.likes() - oldLikes));
            emit dataChanged(index(i), index(i));
            break;
        }
    }
}

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

    comment.setSubmitter(true);
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

    comment.setSubmitter(true);
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

void CommentModel::refresh(bool refreshOlder)
{
    Q_ASSERT(!m_permalink.isEmpty());
    Q_UNUSED(refreshOlder);

    if (m_reply != 0) {
        qWarning("CommentModel::refresh(): Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    if (!m_commentList.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, m_commentList.count() - 1);
        m_commentList.clear();
        endRemoveRows();
    }

    QHash<QString, QString> parameters;
    parameters["sort"] = getSortString(m_sort);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::GET, m_permalink, parameters);

    setBusy(true);
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
    return roles;
}

void CommentModel::onNetworkReplyReceived(QNetworkReply *reply)
{
    disconnect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
               this, SLOT(onNetworkReplyReceived(QNetworkReply*)));
    if (reply != 0) {
        m_reply = reply;
        m_reply->setParent(this);
        connect(m_reply, SIGNAL(finished()), SLOT(onFinished()));
    } else {
        setBusy(false);
    }
}

void CommentModel::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        const QList<CommentObject> comments = Parser::parseCommentList(m_reply->readAll());
        if (!comments.isEmpty()) {
            beginInsertRows(QModelIndex(), m_commentList.count(), m_commentList.count() + comments.count() - 1);
            m_commentList.append(comments);
            endInsertRows();
        }
    } else {
        emit error(m_reply->errorString());
    }

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
    emit commentLoaded();
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
