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
    Q_ENUMS(VoteType)
public:
    enum VoteType {
        Upvote,
        Downvote,
        Unvote
    };

    explicit VoteManager(QObject *parent = 0);

    Q_INVOKABLE void vote(const QString &fullname, VoteType voteType);

signals:
    void voteSuccess(const QString &fullname, int likes);
    void error(const QString &errorString);

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    QString m_fullname;
    VoteType m_voteType;
    QNetworkReply *m_reply;

    static int voteTypeToLikes(VoteType voteType);
};

#endif // VOTEMANAGER_H
