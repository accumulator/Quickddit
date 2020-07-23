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

#ifndef MULTIREDDITOBJECT_H
#define MULTIREDDITOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>
#include <QtCore/QStringList>

class QDateTime;
class MultiredditObjectData;

class MultiredditObject
{
public:
    enum Visibility {
        PrivateVisibility = 0,
        PublicVisibility = 1
    };

    MultiredditObject();
    MultiredditObject(const MultiredditObject &other);
    MultiredditObject &operator=(const MultiredditObject &other);
    ~MultiredditObject();

    QString name() const;
    void setName(const QString &name);

    QString description() const;
    void setDescription(const QString &description);

    QString iconUrl() const;
    void setIconUrl(const QString &iconUrl);

    QDateTime created() const;
    void setCreated(const QDateTime &created);

    QStringList subreddits() const;
    void setSubreddits(const QStringList &subreddits);

    Visibility visibility() const;
    void setVisibility(Visibility visibility);
    void setVisibility(const QString &visibilityStr);

    QString path() const;
    void setPath(const QString &path);

    bool canEdit() const;
    void setCanEdit(bool canEdit);

private:
    QExplicitlySharedDataPointer<MultiredditObjectData> d;
};

#endif // MULTIREDDITOBJECT_H
