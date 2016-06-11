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
    AbstractManager(parent)
{
    m_ready = false;
    m_iden = "";
    m_captchaNeededState = Unknown;
}

void CaptchaManager::request()
{
    // first ask if we need to submit a captcha for this user
    if (m_captchaNeededState == Unknown) {
        requestCaptchaNeeded();
        return;
    }

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");

    doRequest(APIRequest::POST, "/api/new_captcha", SLOT(onRequestFinished(QNetworkReply*)), parameters);

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
            emit error(reply->errorString());
        }
    }
}

void CaptchaManager::requestCaptchaNeeded()
{
    doRequest(APIRequest::GET, "/api/needs_captcha", SLOT(onCaptchaNeededFinished(QNetworkReply*)));
}

void CaptchaManager::onCaptchaNeededFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            QString response = reply->readAll();
            if (response == "false") {
                m_captchaNeededState = False;
                qDebug() << "No captcha needed";
            } else {
                m_captchaNeededState = True;
                qDebug() << "Captcha needed";
            }
        } else {
            emit error(reply->errorString());
            m_captchaNeededState = Error;
        }
    }

    emit captchaNeededChanged();

    // since this slot is only reached as a step-out request-reply by request(), call it now that we have the captcha-needed state.
    // unless we don't need a captcha at all, of course.
    if (m_captchaNeededState != False)
        request();
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

bool CaptchaManager::captchaNeeded()
{
    return (m_captchaNeededState == True || m_captchaNeededState == Error);
}
