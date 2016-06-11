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

#ifndef ABSTRACTMANAGER_H
#define ABSTRACTMANAGER_H

#include <QtCore/QObject>

#include "quickdditmanager.h"
#include "apirequest.h"

class AbstractManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ isBusy NOTIFY busyChanged)
    Q_PROPERTY(QuickdditManager* manager READ manager WRITE setManager)
public:
    explicit AbstractManager(QObject *parent = 0);

    bool isBusy() const;

    QuickdditManager *manager();
    void setManager(QuickdditManager *manager);
    APIRequest *req();

protected:
    void setBusy(bool busy);
    void doRequest(APIRequest::HttpMethod method, const QString &relativeUrl, const char* finishedHandler = 0, const QHash<QString, QString> &parameters = QHash<QString,QString>());

signals:
    void busyChanged();

private slots:
    void onRequestFinished(QNetworkReply* reply);

private:
    bool m_busy;
    QuickdditManager *m_manager;
    APIRequest *m_request;
};

#endif // ABSTRACTMANAGER_H
