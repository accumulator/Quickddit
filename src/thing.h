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

#ifndef THING_H
#define THING_H

#include <QString>
#include <QtCore/QExplicitlySharedDataPointer>

class ThingData;

class Thing
{
public:
    Thing();
    Thing(const Thing &other);
    Thing &operator= (const Thing &other);
    virtual ~Thing();

    QString kind() const;
    void setKind(const QString &kind);
    QString fullname() const;
    void setFullname(const QString &fullname);
    bool saved() const;
    void setSaved(const bool saved);

    QString viewId() const;
    void setViewId(const QString &viewId);

protected:
    QExplicitlySharedDataPointer<ThingData> t;

};

#endif // THING_H
