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

#ifndef SUBREDDITOBJECT_H
#define SUBREDDITOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>

class QUrl;
class SubredditObjectData;

class SubredditObject
{
public:
    enum SubmissionType {
        Any,
        Link,
        Self
    };

    SubredditObject();
    SubredditObject(const SubredditObject &other);
    SubredditObject &operator=(const SubredditObject &other);
    ~SubredditObject();

    QString fullname() const;
    void setFullname(const QString &fullname);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    QString url() const;
    void setUrl(const QString &url);

    QUrl headerImageUrl() const;
    void setHeaderImageUrl(const QUrl &url);

    QString shortDescription() const;
    void setShortDescription(const QString &description);

    QString longDescription() const;
    void setLongDescription(const QString &description);

    int subscribers() const;
    void setSubscribers(int subscribers);

    int activeUsers() const;
    void setActiveUsers(int activeUsers);

    bool isNSFW() const;
    void setNSFW(bool nsfw);

    bool isSubscribed() const;
    void setSubscribed(bool subscribed);

    SubmissionType submissionType() const;
    void setSubmissionType(SubmissionType submissionType);
    void setSubmissionType(const QString &submissionTypeString);

private:
    QExplicitlySharedDataPointer<SubredditObjectData> d;
};

#endif // SUBREDDITOBJECT_H
