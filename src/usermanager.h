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

#ifndef USERMANAGER_H
#define USERMANAGER_H

#include <QtCore/QVariantMap>

#include "abstractmanager.h"
#include "userobject.h"

class UserManager : public AbstractManager
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap user READ user NOTIFY success)
public:
    explicit UserManager(QObject *parent = 0);

    QVariantMap user();

    Q_INVOKABLE void request(const QString &username);

signals:
    void error(const QString &errorString);
    void success();

public slots:

private slots:
    void onFinished(QNetworkReply *reply);

private:
    APIRequest *m_request;
    QVariantMap m_user;

    static QVariantMap toLinkVariantMap(const UserObject &user);
    void abortActiveReply();
};

#endif // USERMANAGER_H
