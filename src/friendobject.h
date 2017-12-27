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

#ifndef FRIENDOBJECT_H
#define FRIENDOBJECT_H

#include <QSharedDataPointer>
#include <QtCore/QDateTime>

class FriendObjectData;

class FriendObject : public QSharedData
{
public:
    FriendObject();
    FriendObject(const FriendObject &);
    FriendObject &operator=(const FriendObject &);
    ~FriendObject();

    QString fullname() const;
    void setFullname(const QString &fullname);

    QString name() const;
    void setName(const QString &name);

    QString comment() const;
    void setComment(const QString &comment);

    QDateTime date() const;
    void setDate(const QDateTime &date);

private:
    QExplicitlySharedDataPointer<FriendObjectData> d;
};

#endif // FRIENDOBJECT_H
