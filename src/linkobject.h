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

#ifndef LINKOBJECT_H
#define LINKOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>
#include <QtCore/QString>

#include "thing.h"

class QDateTime;
class QUrl;
class LinkObjectData;

class LinkObject : public Thing
{
public:
    enum DistinguishedType {
        NotDistinguished,
        DistinguishedByModerator,
        DistinguishedByAdmin,
        DistinguishedBySpecial
    };

    LinkObject();
    LinkObject(const LinkObject &other);
    LinkObject &operator=(const LinkObject &other);
    virtual ~LinkObject();

    /**
     * the name of the author
     * equivalent to "author" in Reddit's JSON
     */
    QString author() const;
    void setAuthor(const QString &author);

    /**
     * the time of the creation of this link
     * equivalent to "created"/"created_utc" in Reddit's JSON
     */
    QDateTime created() const;
    void setCreated(const QDateTime &created);

    /**
     * subreddit of this link excluding the /r/ prefix
     * equivalent to "subreddit" in Reddit's JSON
     */
    QString subreddit() const;
    void setSubreddit(const QString &subreddit);

    /**
     * score of this link (upvotes minus downvotes)
     * equivalent to "score" in Reddit's JSON
     */
    int score() const;
    void setScore(int score);

    /**
     * Indicate the vote of authenticated user on this link
     * 1 = upvoted, 0 = no vote, -1 = downvoted
     */
    int likes() const;
    void setLikes(int likes);

    /**
     * number of comments of this link
     * equivalent to "comment" in Reddit's JSON
     */
    int commentsCount() const;
    void setCommentsCount(int count);

    /**
     * title of this link
     * equivalent to "title" in Reddit's JSON
     */
    QString title() const;
    void setTitle(const QString &title);

    /**
     * the domain of this link, eg. self.reddit.com or imgur.com
     * equivalent to "domain" in Reddit's JSON
     */
    QString domain() const;
    void setDomain(const QString &domain);

    /**
     * the full url of the thumbnail of this link
     * equivalent to "thumbnail" in Reddit's JSON
     */
    QUrl thumbnailUrl() const;
    void setThumbnailUrl(const QUrl &url);

    /**
     * the html text of this link
     * equivalent to "selftext_html" in Reddit's JSON
     */
    QString text() const;
    void setText(const QString &text);

    /**
     * the raw markdown text of this link
     * equivalent to "selftext" in Reddit's JSON
     */
    QString rawText() const;
    void setRawText(const QString &rawText);

    /**
     * the *relative* permalink
     * equivalent to "permalink" in Reddit's JSON
     */
    QString permalink() const;
    void setPermalink(const QString &permalink);

    /**
     * the full url for this link, or same with permalink if this is a self post
     * equivalent to "url" in Reddit's JSON
     */
    QUrl url() const;
    void setUrl(const QUrl &url);

    /**
     * see <http://www.reddit.com/r/redditdev/comments/19ak1b/>
     * equivalent to "distinguished" in Reddit's JSON
     */
    DistinguishedType distinguished() const;
    void setDistinguished(DistinguishedType distinguished);
    void setDistinguished(const QString &distinguishedString);

    /**
     * indicate if this is a sticky post
     * equivalent to "stickied" in Reddit's JSON
     */
    bool isSticky() const;
    void setSticky(bool isSticky);

    /**
     * indicate if this is a NSFW post
     * equivalent to "over_18" in Reddit's JSON
     */
    bool isNSFW() const;
    void setNSFW(bool isNSFW);

    /**
     * indicate if this is a promoted (sponsored) post
     * equivalent to "promoted" in Reddit's JSON
     */
    bool isPromoted() const;
    void setPromoted(bool isPromoted);

    /**
     * the flair text of this link
     * equivalent to link_flair_text in Reddit's JSON
     */
    QString flairText() const;
    void setFlairText(const QString &flairText);

    bool isSelfPost() const;

    inline bool operator ==(const LinkObject &other) const { return fullname() == other.fullname(); }

private:
    QExplicitlySharedDataPointer<LinkObjectData> d;
};

#endif // LINKOBJECT_H
