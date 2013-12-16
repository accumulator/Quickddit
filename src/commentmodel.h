#ifndef COMMENTMODEL_H
#define COMMENTMODEL_H

#include "abstractlistmodelmanager.h"
#include "commentobject.h"
#include "votemanager.h"

class CommentModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(SortType)
    Q_PROPERTY(QString permalink READ permalink WRITE setPermalink NOTIFY permalinkChanged)
    Q_PROPERTY(SortType sort READ sort WRITE setSort NOTIFY sortChanged)
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        AuthorRole,
        BodyRole,
        ScoreRole,
        LikesRole,
        CreatedRole,
        DepthRole,
        IsScoreHiddenRole
    };

    enum SortType {
        ConfidenceSort, // a.k.a. "best"
        TopSort,
        NewSort,
        HotSort,
        ControversialSort,
        OldSort
    };

    explicit CommentModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    QString permalink() const;
    void setPermalink(const QString &permalink);

    SortType sort() const;
    void setSort(SortType sort);

    void changeVote(const QString &fullname, VoteManager::VoteType voteType);

    void refresh(bool refreshOlder);
    Q_INVOKABLE int getParentIndex(int index) const;

signals:
    void permalinkChanged();
    void sortChanged();

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    QString m_permalink;
    SortType m_sort;

    QList<CommentObject> m_commentList;
    QNetworkReply *m_reply;

    static QString getSortString(SortType sort);
};

#endif // COMMENTMODEL_H
