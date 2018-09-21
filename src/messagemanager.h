/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2018  Sander van Grieken

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

#ifndef MESSAGEMANAGER_H
#define MESSAGEMANAGER_H

#include "abstractmanager.h"

class MessageManager : public AbstractManager
{
    Q_OBJECT
public:
    explicit MessageManager(QObject *parent = 0);

    Q_INVOKABLE void reply(const QString &fullname, const QString &rawText);
    Q_INVOKABLE void markRead(const QString &fullname);
    Q_INVOKABLE void markUnread(const QString &fullname);
    Q_INVOKABLE void send(const QString &username, const QString &subject, const QString &rawText);
    Q_INVOKABLE void del(const QString &fullname);

signals:
    void replySuccess();
    void sendSuccess();
    void markReadStatusSuccess(const QString &fullname, bool isUnread);
    void error(const QString &errorString);
    void delSuccess(const QString &fullname);

private slots:
    void onFinished(QNetworkReply *reply);

private:
    QString m_fullname;
    enum Action { Reply, Send, MarkRead, MarkUnread, Delete };
    Action m_action;
};

#endif // MESSAGEMANAGER_H
