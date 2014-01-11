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

#ifndef VOTEMANAGER_H
#define VOTEMANAGER_H

#include "abstractmanager.h"

class VoteManager : public AbstractManager
{
    Q_OBJECT
    Q_ENUMS(Type)
    Q_ENUMS(VoteType)
    Q_PROPERTY(Type type READ type WRITE setType)
    Q_PROPERTY(QObject* model READ model WRITE setModel)
public:
    enum Type {
        Link,
        Comment
    };

    enum VoteType {
        Upvote,
        Downvote,
        Unvote
    };

    explicit VoteManager(QObject *parent = 0);

    Type type() const;
    void setType(Type type);

    QObject *model() const;
    void setModel(QObject *model);

    Q_INVOKABLE void vote(const QString &fullname, VoteType voteType);

signals:
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    Type m_type;
    QObject *m_model;

    QString m_fullname;
    VoteType m_voteType;
    QNetworkReply *m_reply;
};

#endif // VOTEMANAGER_H
