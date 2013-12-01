#ifndef SUBREDDITMODEL_H
#define SUBREDDITMODEL_H

#include <QtCore/QAbstractListModel>

#include "subredditobject.h"

class SubredditModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        DisplayNameRole,
        UrlRole,
        HeaderImageUrlRole,
        ShortDescriptionRole,
        LongDescriptionRole,
        SubscribersRole,
        ActiveUsersRole,
        IsNSFWRole
    };

    explicit SubredditModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    int count() const;
    QString lastFullname() const;

    void append(const QList<SubredditObject> &subredditList);
    void clear();

private:
    QList<SubredditObject> m_subredditList;
};

#endif // SUBREDDITMODEL_H
