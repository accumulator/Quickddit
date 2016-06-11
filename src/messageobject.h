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

#ifndef MESSAGEOBJECT_H
#define MESSAGEOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>

class QDateTime;
class MessageObjectData;

class MessageObject
{
public:
    MessageObject();
    MessageObject(const MessageObject &other);
    MessageObject &operator =(const MessageObject &other);
    ~MessageObject();

    enum DistinguishedType {
        NotDistinguished,
        DistinguishedByModerator,
        DistinguishedByAdmin,
        DistinguishedBySpecial
    };

    QString fullname() const;
    void setFullname(const QString &fullname);

    QString author() const;
    void setAuthor(const QString &author);

    QString destination() const;
    void setDestination(const QString &dest);

    QString body() const;
    void setBody(const QString &body);

    QString rawBody() const;
    void setRawBody(const QString &raw_body);

    QDateTime created() const;
    void setCreated(const QDateTime &created);

    QString subject() const;
    void setSubject(const QString &subject);

    // for comment only
    QString linkTitle() const;
    void setLinkTitle(const QString &title);

    // for comment only
    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    // for comment only
    QString context() const;
    void setContext(const QString &context);

    bool isComment() const;
    void setComment(bool comment);

    bool isUnread() const;
    void setUnread(bool unread);

    DistinguishedType distinguished() const;
    void setDistinguished(DistinguishedType distinguished);
    void setDistinguished(const QString &distinguishedString);

private:
    QExplicitlySharedDataPointer<MessageObjectData> d;
};

#endif // MESSAGEOBJECT_H
