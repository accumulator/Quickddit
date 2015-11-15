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

#include "messageobject.h"

#include <QtCore/QDateTime>

class MessageObjectData : public QSharedData
{
public:
    MessageObjectData() {}

    QString fullname;
    QString author;
    QString destination;
    QString body;
    QString rawBody;
    QDateTime created;
    QString subject;
    QString linkTitle;
    QString subreddit;
    QString context;
    bool isComment;
    bool isUnread;

private:
    Q_DISABLE_COPY(MessageObjectData)
};

MessageObject::MessageObject() :
    d(new MessageObjectData)
{
}

MessageObject::MessageObject(const MessageObject &other) :
    d(other.d)
{
}

MessageObject &MessageObject::operator =(const MessageObject &other)
{
    d = other.d;
    return *this;
}

MessageObject::~MessageObject()
{
}

QString MessageObject::fullname() const
{
    return d->fullname;
}

void MessageObject::setFullname(const QString &fullname)
{
    d->fullname = fullname;
}

QString MessageObject::author() const
{
    return d->author;
}

void MessageObject::setAuthor(const QString &author)
{
    d->author = author;
}

QString MessageObject::destination() const
{
    return d->destination;
}

void MessageObject::setDestination(const QString &dest)
{
    d->destination = dest;
}

QString MessageObject::body() const
{
    return d->body;
}

void MessageObject::setBody(const QString &body)
{
    d->body = body;
}

QString MessageObject::rawBody() const
{
    return d->rawBody;
}

void MessageObject::setRawBody(const QString &raw_body)
{
    d->rawBody = raw_body;
}

QDateTime MessageObject::created() const
{
    return d->created;
}

void MessageObject::setCreated(const QDateTime &created)
{
    d->created = created;
}

QString MessageObject::subject() const
{
    return d->subject;
}

void MessageObject::setSubject(const QString &subject)
{
    d->subject = subject;
}

QString MessageObject::linkTitle() const
{
    return d->linkTitle;
}

void MessageObject::setLinkTitle(const QString &title)
{
    d->linkTitle = title;
}

QString MessageObject::subreddit() const
{
    return d->subreddit;
}

void MessageObject::setSubreddit(const QString &subreddit)
{
    d->subreddit = subreddit;
}

QString MessageObject::context() const
{
    return d->context;
}

void MessageObject::setContext(const QString &context)
{
    d->context = context;
}

bool MessageObject::isComment() const
{
    return d->isComment;
}

void MessageObject::setComment(bool comment)
{
    d->isComment = comment;
}

bool MessageObject::isUnread() const
{
    return d->isUnread;
}

void MessageObject::setUnread(bool unread)
{
    d->isUnread = unread;
}
