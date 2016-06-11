/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

#ifndef SUBREDDITMANAGER_H
#define SUBREDDITMANAGER_H

#include "abstractmanager.h"
#include "subredditmodel.h"

class SubredditManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(SubredditModel* model READ model WRITE setModel)
public:
    explicit SubredditManager(QObject *parent = 0);

    SubredditModel *model() const;
    void setModel(SubredditModel *model);

    Q_INVOKABLE void subscribe(const QString &fullname);
    Q_INVOKABLE void unsubscribe(const QString &fullname);

signals:
    void success();
    void error(const QString &errorString);

private slots:
    void onFinished(QNetworkReply *reply);

private:
    void doSubscribe(const QString &subreddit, bool subscribe);
    void abortActiveReply();

    SubredditModel *m_model;
    bool m_subscribe;
    QString m_fullname;
    APIRequest *m_request;
};

#endif // SUBREDDITMANAGER_H
