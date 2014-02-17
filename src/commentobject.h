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

#ifndef COMMENTOBJECT_H
#define COMMENTOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>
#include <QtCore/QList>

class QDateTime;
class CommentObjectData;

class CommentObject
{
public:
    enum DistinguishedType {
        NotDistinguished,
        DistinguishedByModerator,
        DistinguishedByAdmin,
        DistinguishedBySpecial
    };

    CommentObject();
    CommentObject(const CommentObject &other);
    CommentObject &operator= (const CommentObject &other);
    ~CommentObject();

    QString fullname() const;
    void setFullname(const QString &fullname);

    QString author() const;
    void setAuthor(const QString &author);

    QString body() const;
    void setBody(const QString &body);

    QString rawBody() const;
    void setRawBody(const QString &rawBody);

    int score() const;
    void setScore(int score);

    int likes() const;
    void setLikes(int likes);

    QDateTime created() const;
    void setCreated(const QDateTime &created);

    QDateTime edited() const;
    void setEdited(const QDateTime &edited);

    DistinguishedType distinguished() const;
    void setDistinguished(DistinguishedType distinguished);
    void setDistinguished(const QString &distinguishedString);

    int depth() const;
    void setDepth(int depth);

    bool isSubmitter() const;
    void setSubmitter(bool submitter);

    bool isScoreHidden() const;
    void setScoreHidden(bool scoreHidden);

    QList<QString> moreChildren() const;
    void setMoreChildren(const QList<QString> &children);

    bool isMoreChildren() const;
    void setIsMoreChildren(bool isMoreChildren);

private:
    QExplicitlySharedDataPointer<CommentObjectData> d;
};

#endif // COMMENTOBJECT_H
