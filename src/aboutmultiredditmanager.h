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

#ifndef ABOUTMULTIREDDITMANAGER_H
#define ABOUTMULTIREDDITMANAGER_H

#include "abstractmanager.h"
#include "multiredditobject.h"

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
  #include <QtQml/QQmlParserStatus>
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QQmlParserStatus)
#else
  #include <QtDeclarative/QDeclarativeParserStatus>
  #define QQmlParserStatus QDeclarativeParserStatus
  #define DECL_QMLPARSERSTATUS_INTERFACE Q_INTERFACES(QDeclarativeParserStatus)
#endif

class MultiredditModel;

class AboutMultiredditManager : public AbstractManager, public QQmlParserStatus
{
    Q_OBJECT
    DECL_QMLPARSERSTATUS_INTERFACE
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description NOTIFY multiredditChanged)
    Q_PROPERTY(QString iconUrl READ iconUrl NOTIFY multiredditChanged)
    Q_PROPERTY(QStringList subreddits READ subreddits NOTIFY multiredditChanged)
    Q_PROPERTY(bool canEdit READ canEdit NOTIFY multiredditChanged)
    Q_PROPERTY(MultiredditModel* model READ model WRITE setModel)
public:
    explicit AboutMultiredditManager(QObject *parent = 0);

    void classBegin();
    void componentComplete();

    QString name() const;
    void setName(const QString &name);

    QString description() const;
    QString iconUrl() const;
    QStringList subreddits() const;
    bool canEdit() const;

    MultiredditModel *model() const;
    void setModel(MultiredditModel *model);

    Q_INVOKABLE void addSubreddit(const QString &subreddit);
    Q_INVOKABLE void removeSubreddit(const QString &subreddit);

signals:
    void nameChanged();
    void multiredditChanged();
    void success(const QString &message);
    void error(const QString &errorString);

private slots:
    void onDescriptionFinished(QNetworkReply *reply);
    void onAddFinished(QNetworkReply *reply);
    void onRemoveFinished(QNetworkReply *reply);

private:
    void getDescription();
    void abortActiveRequest();

    MultiredditObject m_multiredditObject;

    QString m_name;
    MultiredditModel *m_model;

    QString toBeRemoveSubreddit;
};

#endif // ABOUTMULTIREDDITMANAGER_H
