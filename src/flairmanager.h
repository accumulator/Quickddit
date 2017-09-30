/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2017  Sander van Grieken

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

#include <QtNetwork/QNetworkReply>

#include "abstractmanager.h"

#ifndef FLAIRMANAGER_H
#define FLAIRMANAGER_H

class FlairManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(QString subreddit READ subreddit WRITE setSubreddit NOTIFY subredditChanged)
    Q_PROPERTY(QVariantList subredditFlairs READ subredditFlairs NOTIFY subredditFlairsChanged)
    Q_PROPERTY(QVariantMap flairs READ flairs NOTIFY flairsChanged)

public:
    explicit FlairManager(QObject *parent = 0);

    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    QVariantList subredditFlairs() const;
    QVariantMap flairs() const;

    Q_INVOKABLE void getFlairSelector(const QString &fullname);
    Q_INVOKABLE void getSubredditFlair();
    Q_INVOKABLE void selectFlair(const QString& fullname, const QString& flairId);
signals:
    void subredditChanged();
    void subredditFlairsChanged();
    void flairsChanged();
    void error(const QString &errorString);

private slots:
    void onSubredditFlairFinished(QNetworkReply *reply);
    void onFlairSelectorFinished(QNetworkReply *reply);
    void onSelectFlairFinished(QNetworkReply *reply);
private:
    QString m_subreddit;
    QVariantList m_subredditFlairs;
    QVariantMap m_flairs;
};

#endif // FLAIRMANAGER_H
