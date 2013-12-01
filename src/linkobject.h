#ifndef LINKOBJECT_H
#define LINKOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>

class QDateTime;
class QUrl;
class LinkObjectData;

class LinkObject
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
    ~LinkObject();

    /**
     * fullname of the link (actually it means id, see http://www.reddit.com/dev/api#fullnames)
     * equivalent to "name" in Reddit's JSON
     */
    QString fullname() const;
    void setFullname(const QString &fullname);

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
     * number of comments of this link
     * equivalent to "comment" in Reddit's JSON
     */
    int commentsCount() const;
    void setCommentsCount(int count);

    /**
     * title of this lnk
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

private:
    QExplicitlySharedDataPointer<LinkObjectData> d;
};

#endif // LINKOBJECT_H
