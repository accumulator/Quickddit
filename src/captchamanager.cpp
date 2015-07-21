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
#include <QDebug>

#include "captchamanager.h"
#include "parser.h"

CaptchaManager::CaptchaManager(QObject *parent) :
    AbstractManager(parent), m_request(0)
{
    m_ready = false;
    m_iden = "";
}

void CaptchaManager::request()
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/new_captcha", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onRequestFinished(QNetworkReply*)));

    setBusy(true);

    m_ready = false;
    m_iden = "";
    emit readyChanged();
}

void CaptchaManager::onRequestFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            QString iden = Parser::parseNewCaptchaResponse(reply->readAll());
            qDebug() << "captcha received iden " << iden;
            m_iden = iden;
            m_ready = true;
            emit readyChanged();
        } else {
            error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

QUrl CaptchaManager::imageUrl()
{
    qDebug() << "URL retrieved for iden" << m_iden;
    // TODO : non hardcoded base URL
    return QUrl("https://www.reddit.com/captcha/" + m_iden);
}

bool CaptchaManager::ready()
{
    qDebug() << "ready?" << m_ready;
    return m_ready;
}

QString CaptchaManager::iden()
{
    return m_iden;
}

void CaptchaManager::abortActiveReply()
{
    if (m_request != 0) {
        qWarning("CaptchaManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }
}
