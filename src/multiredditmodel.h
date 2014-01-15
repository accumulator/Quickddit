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

#ifndef MULTIREDDITMODEL_H
#define MULTIREDDITMODEL_H

#include "abstractlistmodelmanager.h"
#include "multiredditobject.h"

class MultiredditModel : public AbstractListModelManager
{
    Q_OBJECT
public:
    enum Roles {
        NameRole = Qt::UserRole
    };

    explicit MultiredditModel(QObject *parent = 0);
    
    void classBegin();
    void componentComplete();

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    void refresh(bool refreshOlder);

protected:
    QHash<int, QByteArray> customRoleNames() const;

private slots:
    void onNetworkReplyReceived(QNetworkReply *reply);
    void onFinished();

private:
    QList<MultiredditObject> m_multiredditList;
    QNetworkReply *m_reply;
};

#endif // MULTIREDDITMODEL_H
