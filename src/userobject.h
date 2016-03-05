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

#ifndef USEROBJECT_H
#define USEROBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>
#include <QtCore/QStringList>
#include <QtCore/QDateTime>

class UserObjectData;

class UserObject
{
public:
    UserObject();
    UserObject(const UserObject &other);
    UserObject &operator=(const UserObject &other);
    ~UserObject();

    QString name() const;
    void setName(const QString &name);

    QString id() const;
    void setId(const QString &id);

    int linkKarma() const;
    void setLinkKarma(const int karma);

    int commentKarma() const;
    void setCommentKarma(const int karma);

    bool isGold() const;
    void setGold(const bool isGold);

    bool hasVerifiedEmail() const;
    void setVerifiedEmail(const bool hasVerifiedEmail);

    bool isMod() const;
    void setMod(const bool isMod);

    bool isHideFromRobots() const;
    void setHideFromRobots(const bool isHideFromRobots);

    bool isFriend() const;
    void setFriend(const bool isFriend);

    QDateTime created() const;
    void setCreated(const QDateTime &created);

private:
    QExplicitlySharedDataPointer<UserObjectData> d;
};

#endif // USEROBJECT_H
