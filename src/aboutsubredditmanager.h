/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

#ifndef ABOUTSUBREDDITMANAGER_H
#define ABOUTSUBREDDITMANAGER_H

#include <QtCore/QUrl>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtQml/QQmlParserStatus>
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QQmlParserStatus)
#else
  #include <QtDeclarative/QDeclarativeParserStatus>
  #define QQmlParserStatus QDeclarativeParserStatus
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QDeclarativeParserStatus)
#endif

#include "abstractmanager.h"
#include "subredditobject.h"

class AboutSubredditManager : public AbstractManager, public QQmlParserStatus
{
    Q_OBJECT
    DECL_QMLPARSERSTATUS_INTERFACE
    Q_ENUMS(SubmissionType)
    Q_PROPERTY(bool isValid READ isValid NOTIFY dataChanged)
    Q_PROPERTY(QString url READ url NOTIFY dataChanged)
    Q_PROPERTY(QUrl headerImageUrl READ headerImageUrl NOTIFY dataChanged)
    Q_PROPERTY(QString shortDescription READ shortDescription NOTIFY dataChanged)
    Q_PROPERTY(QString longDescription READ longDescription NOTIFY dataChanged)
    Q_PROPERTY(int subscribers READ subscribers NOTIFY dataChanged)
    Q_PROPERTY(int activeUsers READ activeUsers NOTIFY dataChanged)
    Q_PROPERTY(bool isNSFW READ isNSFW NOTIFY dataChanged)
    Q_PROPERTY(bool isSubscribed READ isSubscribed NOTIFY dataChanged)
    Q_PROPERTY(SubmissionType submissionType READ submissionType NOTIFY dataChanged)
    Q_PROPERTY(bool isContributor READ isContributor NOTIFY dataChanged)
    Q_PROPERTY(QString subreddit READ subreddit WRITE setSubreddit NOTIFY subredditChanged)
public:
    enum SubmissionType {
        Any,
        Link,
        Self
    };

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
    SubmissionType submissionType() const;
    bool isContributor() const;

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
    void onFinished(QNetworkReply *reply);
    void onSubscribeFinished(QNetworkReply *reply);

private:
    QString m_subreddit;
    SubredditObject m_subredditObject;

    APIRequest *m_request;
};

#endif // ABOUTSUBREDDITMANAGER_H
