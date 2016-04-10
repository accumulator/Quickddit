/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
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

#ifndef COMMENTOBJECT_H
#define COMMENTOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>
#include <QtCore/QList>

#include "thing.h"

class QDateTime;
class CommentObjectData;

class CommentObject : public Thing
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
    virtual ~CommentObject();

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

    int moreChildrenCount() const;
    void setMoreChildrenCount(int count);

    bool isMoreChildren() const;
    void setIsMoreChildren(bool isMoreChildren);

    bool isCollapsed() const;
    void setIsCollapsed(bool isCollapsed);

    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    QString linkTitle() const;
    void setLinkTitle(const QString &linkTitle);

    QString linkId() const;
    void setLinkId(const QString &linkId);

    bool isArchived() const;
    void setArchived(bool archived);

    bool isStickied() const;
    void setStickied(bool stickied);

    int gilded() const;
    void setGilded(int gilded);


private:
    QExplicitlySharedDataPointer<CommentObjectData> d;
};

#endif // COMMENTOBJECT_H
