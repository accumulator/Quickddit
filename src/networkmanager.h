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

#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QtCore/QObject>

class QNetworkAccessManager;
class QNetworkReply;
class QUrl;

class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = 0);

    QNetworkReply *createGetRequest(const QUrl &url, const QByteArray &authHeader);
    QNetworkReply *createPostRequest(const QUrl &url, const QByteArray &data,
                                     const QByteArray &authHeader);

    QString downloadCounter() const;

signals:
    void downloadCounterChanged();

private slots:
    void increaseDownloadCounter(QNetworkReply *reply);

private:
    Q_DISABLE_COPY(NetworkManager)

    QNetworkAccessManager *m_networkAccessManager;
    qint64 m_downloadCounter; // in bytes
    QString m_downloadCounterStr; // in MB
};

#endif // NETWORKMANAGER_H
