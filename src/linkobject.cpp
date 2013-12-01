#include "linkobject.h"

#include <QtCore/QSharedData>
#include <QtCore/QDateTime>
#include <QtCore/QUrl>

class LinkObjectData : public QSharedData
{
public:
    LinkObjectData() : score(0), commentsCount(0), isSticky(false), isNSFW(false) {}

    QString fullname;
    QString author;
    QDateTime created;
    QString subreddit;
    int score;
    int commentsCount;
    QString title;
    QString domain;
    QUrl thumbnailUrl;
    QString text;
    QString permalink;
    QUrl url;
    LinkObject::DistinguishedType distinguished;
    bool isSticky;
    bool isNSFW;

private:
    Q_DISABLE_COPY(LinkObjectData)
};

LinkObject::LinkObject() :
    d(new LinkObjectData)
{
}

LinkObject::LinkObject(const LinkObject &other) :
    d(other.d)
{
}

LinkObject &LinkObject::operator =(const LinkObject &other)
{
    d = other.d;
    return *this;
}

LinkObject::~LinkObject()
{
}

QString LinkObject::fullname() const
{
    return d->fullname;
}

void LinkObject::setFullname(const QString &fullname)
{
    d->fullname = fullname;
}

QString LinkObject::author() const
{
    return d->author;
}

void LinkObject::setAuthor(const QString &author)
{
    d->author = author;
}

QDateTime LinkObject::created() const
{
    return d->created;
}

void LinkObject::setCreated(const QDateTime &created)
{
    d->created = created;
}

QString LinkObject::subreddit() const
{
    return d->subreddit;
}

void LinkObject::setSubreddit(const QString &subreddit)
{
    d->subreddit = subreddit;
}

int LinkObject::score() const
{
    return d->score;
}

void LinkObject::setScore(int score)
{
    d->score = score;
}

int LinkObject::commentsCount() const
{
    return d->commentsCount;
}

void LinkObject::setCommentsCount(int count)
{
    d->commentsCount = count;
}

QString LinkObject::title() const
{
    return d->title;
}

void LinkObject::setTitle(const QString &title)
{
    d->title = title;
}

QString LinkObject::domain() const
{
    return d->domain;
}

void LinkObject::setDomain(const QString &domain)
{
    d->domain = domain;
}

QUrl LinkObject::thumbnailUrl() const
{
    return d->thumbnailUrl;
}

void LinkObject::setThumbnailUrl(const QUrl &url)
{
    d->thumbnailUrl = url;
}

QString LinkObject::text() const
{
    return d->text;
}

void LinkObject::setText(const QString &text)
{
    d->text = text;
}

QString LinkObject::permalink() const
{
    return d->permalink;
}

void LinkObject::setPermalink(const QString &permalink)
{
    d->permalink = permalink;
}

QUrl LinkObject::url() const
{
    return d->url;
}

void LinkObject::setUrl(const QUrl &url)
{
    d->url = url;
}

LinkObject::DistinguishedType LinkObject::distinguished() const
{
    return d->distinguished;
}

void LinkObject::setDistinguished(DistinguishedType distinguished)
{
    d->distinguished = distinguished;
}

void LinkObject::setDistinguished(const QString &distinguishedString)
{
    if (distinguishedString.isEmpty())
        d->distinguished = NotDistinguished;
    else if (distinguishedString == "moderator")
        d->distinguished = DistinguishedByModerator;
    else if (distinguishedString == "admin")
        d->distinguished = DistinguishedByAdmin;
    else if (distinguishedString == "special")
        d->distinguished = DistinguishedBySpecial;
}

bool LinkObject::isSticky() const
{
    return d->isSticky;
}

void LinkObject::setSticky(bool isSticky)
{
    d->isSticky = isSticky;
}

bool LinkObject::isNSFW() const
{
    return d->isNSFW;
}

void LinkObject::setNSFW(bool isNSFW)
{
    d->isNSFW = isNSFW;
}
