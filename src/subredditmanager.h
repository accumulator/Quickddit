#ifndef SUBREDDITMANAGER_H
#define SUBREDDITMANAGER_H

#include "abstractmanager.h"

class SubredditModel;

class SubredditManager : public AbstractManager
{
    Q_OBJECT
    Q_ENUMS(Section)
    Q_PROPERTY(SubredditModel* model READ model NOTIFY modelChanged)
    Q_PROPERTY(Section section READ section WRITE setSection NOTIFY sectionChanged)
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
public:
    enum Section {
        PopularSection,
        NewSection,
        UserAsSubscriberSection,
        UserAsContributorSection,
        UserAsModeratorSection,
        SearchSection
    };

    explicit SubredditManager(QObject *parent = 0);

    SubredditModel *model() const;

    Section section() const;
    void setSection(Section section);

    QString query() const;
    void setQuery(const QString &query);
    
    Q_INVOKABLE void refresh(bool refreshOlder);

signals:
    void modelChanged();
    void sectionChanged();
    void queryChanged();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    SubredditModel *m_model;
    Section m_section;
    QString m_query;

    QNetworkReply *m_reply;
};

#endif // SUBREDDITMANAGER_H
