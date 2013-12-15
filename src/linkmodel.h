#ifndef LINKMODEL_H
#define LINKMODEL_H

#include <QtCore/QAbstractListModel>

#include "linkobject.h"
#include "votemanager.h"

class LinkModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        AuthorRole,
        CreatedRole,
        SubredditRole,
        ScoreRole,
        LikesRole,
        CommentsCountRole,
        TitleRole,
        DomainRole,
        ThumbnailUrlRole,
        TextRole,
        PermalinkRole,
        UrlRole,
        IsStickyRole,
        IsNSFWRole
    };

    explicit LinkModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    int count() const;
    QString lastFullname() const;

    void append(const QList<LinkObject> &linkList);
    void clear();

    void changeVote(const QString &fullname, VoteManager::VoteType voteType);

private:
    QList<LinkObject> m_linkList;
};

#endif // LINKMODEL_H
