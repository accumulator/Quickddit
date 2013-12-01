#ifndef LINKMODEL_H
#define LINKMODEL_H

#include <QtCore/QAbstractListModel>

#include "linkobject.h"

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

private:
    QList<LinkObject> m_linkList;
};

#endif // LINKMODEL_H
