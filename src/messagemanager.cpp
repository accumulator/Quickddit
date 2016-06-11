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
    AbstractManager(parent), m_request(0)
{
}

void MessageManager::reply(const QString &fullname, const QString &rawText)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", fullname);
    m_fullname = fullname;
    m_action = Reply;

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/comment", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void MessageManager::send(const QString &username, const QString &subject, const QString &rawText, const QString &captcha, const QString &iden)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("subject", subject);
    parameters.insert("text", rawText);
    parameters.insert("to", username);
    // captcha, if defined
    if (captcha != "") {
        parameters.insert("captcha", captcha);
        parameters.insert("iden", iden);
    }
    //parameters.insert("from_sr", from subreddit);

    m_action = Send;

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/compose", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void MessageManager::markRead(const QString &fullname)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_fullname = fullname;
    m_action = MarkRead;

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/read_message", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void MessageManager::markUnread(const QString &fullname)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_fullname = fullname;
    m_action = MarkUnread;

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/unread_message", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
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

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void MessageManager::abortActiveReply()
{
    if (m_request != 0) {
        qWarning("MessageManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }
}
