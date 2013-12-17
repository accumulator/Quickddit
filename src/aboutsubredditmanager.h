#ifndef ABOUTSUBREDDITMANAGER_H
#define ABOUTSUBREDDITMANAGER_H

#include <QtCore/QUrl>
#include <QtDeclarative/QDeclarativeParserStatus>

#include "abstractmanager.h"
#include "subredditobject.h"

class AboutSubredditManager : public AbstractManager, public QDeclarativeParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QDeclarativeParserStatus)
    Q_PROPERTY(bool isValid READ isValid NOTIFY dataChanged)
    Q_PROPERTY(QString url READ url NOTIFY dataChanged)
    Q_PROPERTY(QUrl headerImageUrl READ headerImageUrl NOTIFY dataChanged)
    Q_PROPERTY(QString shortDescription READ shortDescription NOTIFY dataChanged)
    Q_PROPERTY(QString longDescription READ longDescription NOTIFY dataChanged)
    Q_PROPERTY(int subscribers READ subscribers NOTIFY dataChanged)
    Q_PROPERTY(int activeUsers READ activeUsers NOTIFY dataChanged)
    Q_PROPERTY(bool isNSFW READ isNSFW NOTIFY dataChanged)
    Q_PROPERTY(bool isSubscribed READ isSubscribed NOTIFY dataChanged)

    Q_PROPERTY(QString subreddit READ subreddit WRITE setSubreddit NOTIFY subredditChanged)
public:
    explicit AboutSubredditManager(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    bool isValid() const;
    QString url() const;
    QUrl headerImageUrl() const;
    QString shortDescription() const;
    QString longDescription() const;
    int subscribers() const;
    int activeUsers() const;
    bool isNSFW() const;
    bool isSubscribed() const;

    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    Q_INVOKABLE void refresh();

    Q_INVOKABLE void subscribeOrUnsubscribe();

signals:
    void dataChanged();
    void subredditChanged();
    void subscribeSuccess();
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

    void onSubscribeNetworkReplyReceived(QNetworkReply *reply);
    void onSubscribeFinished();

private:
    QString m_subreddit;
    SubredditObject m_subredditObject;

    QNetworkReply *m_reply;
};

#endif // ABOUTSUBREDDITMANAGER_H
