/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

#ifndef USERTHINGMODEL_H
#define USERTHINGMODEL_H

#include "abstractlistmodelmanager.h"
#include "parser.h"
#include "commentobject.h"

class UserThingModelData;

class UserThingModel : public AbstractListModelManager
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
public:
    enum Roles {
        KindRole = Qt::UserRole,
        CommentRole
    };

    explicit UserThingModel(QObject *parent = 0);

    void classBegin();
    void componentComplete();
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    void refresh(bool refreshOlder);

    QString username() const;
    void setUsername(const QString &username);

signals:
    void usernameChanged();

public slots:

private slots:
    void onFinished(QNetworkReply *reply);

protected:
    QHash<int, QByteArray> customRoleNames() const;

private:
    QString m_username;
    Listing<CommentObject> m_commentList;
    APIRequest *m_request;

    QVariantMap commentData(const CommentObject o) const;

    void abortActiveReply();
};

#endif // USERTHINGMODEL_H
