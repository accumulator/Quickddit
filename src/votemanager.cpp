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

#include <QtNetwork/QNetworkReply>

#include "votemanager.h"

VoteManager::VoteManager(QObject *parent) :
    AbstractManager(parent)
{
}

void VoteManager::vote(const QString &fullname, VoteManager::VoteType voteType)
{
    m_fullname = fullname;
    m_voteType = voteType;

    QHash<QString, QString> parameters;
    parameters["id"] = m_fullname;
    parameters["dir"] = QString::number(voteTypeToLikes(m_voteType));

    doRequest(APIRequest::POST, "/api/vote", SLOT(onFinished(QNetworkReply*)), parameters);
}

void VoteManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError)
            emit voteSuccess(m_fullname, voteTypeToLikes(m_voteType));
        else
            emit error(reply->errorString());
    }
}

int VoteManager::voteTypeToLikes(VoteType voteType)
{
    switch (voteType) {
    case Upvote: return 1;
    case Downvote: return -1;
    case Unvote: return 0;
    // shouldn't happens
    default: qFatal("VoteManager::voteTypeToLikes(): Invalid VoteType"); return 0;
    }
}
