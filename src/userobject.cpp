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

#include "userobject.h"

#include <QtCore/QSharedData>
#include <QtCore/QDateTime>

class UserObjectData : public QSharedData
{
public:
    UserObjectData() {}

    QString name;
    QString id;
    QDateTime created;
    bool isFriend;
    bool isMod;
    bool hasVerifiedEmail;
    bool isGold;
    bool isHideFromRobots;
    int linkKarma;
    int commentKarma;

private:
    Q_DISABLE_COPY(UserObjectData)
};

UserObject::UserObject() :
    d(new UserObjectData)
{
}

UserObject::UserObject(const UserObject &other) :
    d(other.d)
{
}

UserObject &UserObject::operator =(const UserObject &other)
{
    d = other.d;
    return *this;
}

UserObject::~UserObject()
{
}


QString UserObject::name() const
{
    return d->name;
}

void UserObject::setName(const QString &name)
{
    d->name = name;
}


QString UserObject::id() const
{
    return d->id;
}

void UserObject::setId(const QString &id)
{
    d->id = id;
}


int UserObject::linkKarma() const
{
    return d->linkKarma;
}

void UserObject::setLinkKarma(const int karma)
{
    d->linkKarma = karma;
}


int UserObject::commentKarma() const
{
    return d->commentKarma;
}

void UserObject::setCommentKarma(const int karma)
{
    d->commentKarma = karma;
}


bool UserObject::isGold() const
{
    return d->isGold;
}

void UserObject::setGold(const bool isGold)
{
    d->isGold = isGold;
}


bool UserObject::hasVerifiedEmail() const
{
    return d->commentKarma;
}

void UserObject::setVerifiedEmail(const bool hasVerifiedEmail)
{
    d->hasVerifiedEmail = hasVerifiedEmail;
}


bool UserObject::isMod() const
{
    return d->isMod;
}

void UserObject::setMod(const bool isMod)
{
    d->isMod = isMod;
}


bool UserObject::isHideFromRobots() const
{
    return d->isHideFromRobots;
}

void UserObject::setHideFromRobots(const bool isHideFromRobots)
{
    d->isHideFromRobots = isHideFromRobots;
}


bool UserObject::isFriend() const
{
    return d->isFriend;
}

void UserObject::setFriend(const bool isFriend)
{
    d->isFriend = isFriend;
}


QDateTime UserObject::created() const
{
    return d->created;
}

void UserObject::setCreated(const QDateTime &created)
{
    d->created = created;
}
