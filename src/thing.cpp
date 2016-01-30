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

#include <QtCore/QSharedData>

#include "thing.h"

class ThingData : public QSharedData
{
public:
    ThingData() {}

    QString kind;
    QString fullname;

private:
    Q_DISABLE_COPY(ThingData)
};

Thing::Thing()
    : t(new ThingData)
{
}

Thing::Thing(const Thing &other)
    : t(other.t)
{
}

Thing &Thing::operator =(const Thing &other)
{
    t = other.t;
    return *this;
}

Thing::~Thing()
{
}

QString Thing::fullname() const
{
    return t->fullname;
}

void Thing::setFullname(const QString &fullname)
{
    t->fullname = fullname;
}


QString Thing::kind() const
{
    return t->kind;
}

void Thing::setKind(const QString &kind)
{
    t->kind = kind;
}
