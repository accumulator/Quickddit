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

#include "friendobject.h"

class FriendObjectData : public QSharedData
{
public:
    FriendObjectData() {}

    QString fullname;
    QString name;
    QString comment;
    QDateTime date;

private:
    Q_DISABLE_COPY(FriendObjectData)
};

FriendObject::FriendObject() : d(new FriendObjectData)
{
}

FriendObject::FriendObject(const FriendObject &other) : d(other.d)
{
}

FriendObject &FriendObject::operator=(const FriendObject &other)
{
    if (this != &other)
        d = other.d;
    return *this;
}

FriendObject::~FriendObject()
{
}

QString FriendObject::fullname() const
{
    return d->fullname;
}

void FriendObject::setFullname(const QString &fullname)
{
    d->fullname = fullname;
}

QString FriendObject::name() const
{
    return d->name;
}

void FriendObject::setName(const QString &name)
{
    d->name = name;
}

QString FriendObject::comment() const
{
    return d->comment;
}

void FriendObject::setComment(const QString &comment)
{
    d->comment = comment;
}

QDateTime FriendObject::date() const
{
    return d->date;
}

void FriendObject::setDate(const QDateTime &date)
{
    d->date = date;
}
