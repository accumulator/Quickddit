#ifndef ABOUTSUBREDDITMANAGER_H
#define ABOUTSUBREDDITMANAGER_H

#include <QtCore/QUrl>

#include "abstractmanager.h"
#include "subredditobject.h"

class AboutSubredditManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(QString displayName READ displayName NOTIFY aboutChanged)
    Q_PROPERTY(QString url READ url NOTIFY aboutChanged)
    Q_PROPERTY(QUrl headerImageUrl READ headerImageUrl NOTIFY aboutChanged)
    Q_PROPERTY(QString shortDescription READ shortDescription NOTIFY aboutChanged)
    Q_PROPERTY(QString longDescription READ longDescription NOTIFY aboutChanged)
    Q_PROPERTY(int subscribers READ subscribers NOTIFY aboutChanged)
    Q_PROPERTY(int activeUsers READ activeUsers NOTIFY aboutChanged)
public:
    explicit AboutSubredditManager(QObject *parent = 0);

    QString displayName() const;
    QString url() const;
    QUrl headerImageUrl() const;
    QString shortDescription() const;
    QString longDescription() const;
    int subscribers() const;
    int activeUsers() const;
    
    Q_INVOKABLE void refresh(const QString &subreddit);

signals:
    void aboutChanged();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    SubredditObject m_subredditObject;

    QNetworkReply *m_reply;
};

#endif // ABOUTSUBREDDITMANAGER_H
