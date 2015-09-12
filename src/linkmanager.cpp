/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2015  Sander van Grieken

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

#include "linkmanager.h"

LinkManager::LinkManager(QObject *parent) :
    AbstractManager(parent), m_request(0)
{
}

void LinkManager::submit(const QString &subreddit, const QString &captcha, const QString &iden, const QString &title, const QString& url, const QString& text)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    // captcha
    parameters.insert("captcha", captcha);
    parameters.insert("iden", iden);
    // self?
    parameters.insert("kind", url.isEmpty() ? "self" : "link");
    if (!url.isEmpty())
        parameters.insert("url", url);
    // basic
    parameters.insert("sr", subreddit);
    parameters.insert("text", text);
    parameters.insert("title", title);

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/submit", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void LinkManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            emit success(tr("The link has been added"));
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void LinkManager::abortActiveReply()
{
    if (m_request != 0) {
        qWarning("LinkManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }
}
