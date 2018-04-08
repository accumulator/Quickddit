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

#include "messagemanager.h"

#include <QtNetwork/QNetworkReply>

MessageManager::MessageManager(QObject *parent) :
    AbstractManager(parent)
{
}

void MessageManager::reply(const QString &fullname, const QString &rawText)
{
    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", fullname);
    m_fullname = fullname;
    m_action = Reply;

    doRequest(APIRequest::POST, "/api/comment", SLOT(onFinished(QNetworkReply*)), parameters);
}

void MessageManager::send(const QString &username, const QString &subject, const QString &rawText)
{
    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("subject", subject);
    parameters.insert("text", rawText);
    parameters.insert("to", username);

    m_action = Send;

    doRequest(APIRequest::POST, "/api/compose", SLOT(onFinished(QNetworkReply*)), parameters);
}

void MessageManager::markRead(const QString &fullname)
{
    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_fullname = fullname;
    m_action = MarkRead;

    doRequest(APIRequest::POST, "/api/read_message", SLOT(onFinished(QNetworkReply*)), parameters);
}

void MessageManager::markUnread(const QString &fullname)
{
    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_fullname = fullname;
    m_action = MarkUnread;

    doRequest(APIRequest::POST, "/api/unread_message", SLOT(onFinished(QNetworkReply*)), parameters);
}

void MessageManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            switch (m_action) {
            case Reply: emit replySuccess(); break;
            case Send: emit sendSuccess(); break;
            case MarkRead: emit markReadStatusSuccess(m_fullname, false); break;
            case MarkUnread: emit markReadStatusSuccess(m_fullname, true); break;
            default: qFatal("MessageManager::onFinished(): Invalid m_action"); break;
            }
        } else {
            emit error(reply->errorString());
        }
    }
}
