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

#include "multiredditobject.h"

#include <QtCore/QSharedData>
#include <QtCore/QDateTime>

class MultiredditObjectData : public QSharedData
{
public:
    MultiredditObjectData() : visibility(MultiredditObject::PrivateVisibility), canEdit(false) {}

    QString name;
    QString description;
    QString iconUrl;
    QDateTime created;
    QStringList subreddits;
    MultiredditObject::Visibility visibility;
    QString path;
    bool canEdit;

private:
    Q_DISABLE_COPY(MultiredditObjectData)
};

MultiredditObject::MultiredditObject() :
    d(new MultiredditObjectData)
{
}

MultiredditObject::MultiredditObject(const MultiredditObject &other) :
    d(other.d)
{
}

MultiredditObject &MultiredditObject::operator =(const MultiredditObject &other)
{
    d = other.d;
    return *this;
}

MultiredditObject::~MultiredditObject()
{
}

QString MultiredditObject::name() const
{
    return d->name;
}

void MultiredditObject::setName(const QString &name)
{
    d->name = name;
}

QString MultiredditObject::description() const
{
    return d->description;
}

void MultiredditObject::setDescription(const QString &description)
{
    d->description = description;
}

QString MultiredditObject::iconUrl() const
{
    return d->iconUrl;
}

void MultiredditObject::setIconUrl(const QString &iconUrl)
{
    d->iconUrl = iconUrl;
}

QDateTime MultiredditObject::created() const
{
    return d->created;
}

void MultiredditObject::setCreated(const QDateTime &created)
{
    d->created = created;
}

QStringList MultiredditObject::subreddits() const
{
    return d->subreddits;
}

void MultiredditObject::setSubreddits(const QStringList &subreddits)
{
    d->subreddits = subreddits;
}

MultiredditObject::Visibility MultiredditObject::visibility() const
{
    return d->visibility;
}

void MultiredditObject::setVisibility(MultiredditObject::Visibility visibility)
{
    d->visibility = visibility;
}

void MultiredditObject::setVisibility(const QString &visibilityStr)
{
    if (visibilityStr == "private")
        d->visibility = PrivateVisibility;
    else if (visibilityStr == "public")
        d->visibility = PublicVisibility;
    else
        qWarning("MultiredditObject::setVisibility(): Unknown visibilityStr: %s", qPrintable(visibilityStr));
}

QString MultiredditObject::path() const
{
    return d->path;
}

void MultiredditObject::setPath(const QString &path)
{
    d->path = path;
}

bool MultiredditObject::canEdit() const
{
    return d->canEdit;
}

void MultiredditObject::setCanEdit(bool canEdit)
{
    d->canEdit = canEdit;
}
