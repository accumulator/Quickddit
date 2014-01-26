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

#include "networkmanager.h"

#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>

#if defined(Q_OS_HARMATTAN)
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (MeeGo Harmattan)";
#elif defined(Q_OS_SAILFISH)
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (SailfishOS)";
#elif defined(Q_WS_SIMULATOR)
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (Qt Simulator)";
#else
static const QByteArray USER_AGENT = QByteArray("Quickddit/") + APP_VERSION + " (Unknown)";
#endif

NetworkManager::NetworkManager(QObject *parent) :
    QObject(parent), m_networkAccessManager(new QNetworkAccessManager(this)),
    m_downloadCounter(0), m_downloadCounterStr("0.00")
{
    connect(m_networkAccessManager, SIGNAL(finished(QNetworkReply*)),
            SLOT(increaseDownloadCounter(QNetworkReply*)));
}

QNetworkReply *NetworkManager::createGetRequest(const QUrl &url, const QByteArray &authHeader)
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setRawHeader("User-Agent", USER_AGENT);
    if (!authHeader.isEmpty())
        request.setRawHeader("Authorization", authHeader);
    return m_networkAccessManager->get(request);
}

QNetworkReply *NetworkManager::createPostRequest(const QUrl &url, const QByteArray &data,
                                                 const QByteArray &authHeader)
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setRawHeader("User-Agent", USER_AGENT);
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    if (!authHeader.isEmpty())
        request.setRawHeader("Authorization", authHeader);
    return m_networkAccessManager->post(request, data);
}

QString NetworkManager::downloadCounter() const
{
    return m_downloadCounterStr;
}

void NetworkManager::increaseDownloadCounter(QNetworkReply *reply)
{
    m_downloadCounter += reply->size();
    const QString downloadCounterStr = QString::number(qreal(m_downloadCounter) / 1024 / 1024, 'f', 2);
    if (m_downloadCounterStr != downloadCounterStr) {
        m_downloadCounterStr = downloadCounterStr;
        emit downloadCounterChanged();
    }
}
