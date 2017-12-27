/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2017  Sander van Grieken

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

#ifndef FRIENDMODEL_H
#define FRIENDMODEL_H

#include <QtNetwork/QNetworkReply>
#include <QDebug>

#include "abstractlistmodelmanager.h"
#include "parser.h"
#include "friendobject.h"

class FriendModel : public AbstractListModelManager
{
    Q_OBJECT
public:
    enum Roles {
        FullnameRole = Qt::UserRole,
        NameRole,
        CommentRole,
        DateRole
    };

    explicit FriendModel(QObject *parent = 0);
    ~FriendModel();

    void classBegin();
    void componentComplete();
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    void refresh(bool refreshOlder);

private slots:
    void onFinished(QNetworkReply *reply);

protected:
    QHash<int, QByteArray> customRoleNames() const;

private:
    Listing<FriendObject> m_friendList;

};

#endif // FRIENDMODEL_H
