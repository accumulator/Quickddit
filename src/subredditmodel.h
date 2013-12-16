#ifndef SUBREDDITMODEL_H
#define SUBREDDITMODEL_H

#include "abstractlistmodelmanager.h"
#include "subredditobject.h"

class SubredditModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_ENUMS(Section)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
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

    enum Section {
        PopularSection,
        NewSection,
        UserAsSubscriberSection,
        UserAsContributorSection,
        UserAsModeratorSection,
        SearchSection
    };

    explicit SubredditModel(QObject *parent = 0);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    Section section() const;
    void setSection(Section section);

    QString query() const;
    void setQuery(const QString &query);

    void refresh(bool refreshOlder);

signals:
    void sectionChanged();
    void queryChanged();

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    Section m_section;
    QString m_query;

    QList<SubredditObject> m_subredditList;
    QNetworkReply *m_reply;
};

#endif // SUBREDDITMODEL_H
