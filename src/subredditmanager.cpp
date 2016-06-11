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

#include <QtNetwork/QNetworkReply>
#include <QDebug>

#include "subredditmanager.h"

SubredditManager::SubredditManager(QObject *parent) :
    AbstractManager(parent), m_model(0)
{
}

SubredditModel *SubredditManager::model() const
{
    return m_model;
}

void SubredditManager::setModel(SubredditModel *model)
{
    m_model = model;
}

void SubredditManager::subscribe(const QString &fullname)
{
    doSubscribe(fullname, true);
}

void SubredditManager::unsubscribe(const QString &fullname)
{
    doSubscribe(fullname, false);
}

void SubredditManager::doSubscribe(const QString &fullname, bool subscribe)
{
    QHash<QString, QString> parameters;
    parameters["sr"] = fullname;
    if (subscribe)
        parameters["action"] = "sub";
    else
        parameters["action"] = "unsub";

    m_subscribe = subscribe;
    m_fullname = fullname;

    doRequest(APIRequest::POST, "/api/subscribe", SLOT(onFinished(QNetworkReply*)), parameters);
}

void SubredditManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            emit success();
            if (m_model) {
                m_model->deleteSubreddit(m_fullname);
            }
        } else {
            emit error(reply->errorString());
        }
    }
}
