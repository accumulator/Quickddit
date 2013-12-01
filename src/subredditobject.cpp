#include "subredditobject.h"

#include <QtCore/QUrl>
#include <QtCore/QSharedData>

class SubredditObjectData : public QSharedData
{
public:
    SubredditObjectData() : subscribers(0), activeUsers(0), isNSFW(false) {}

    QString fullname;
    QString displayName;
    QString url;
    QUrl headerImageUrl;
    QString shortDescription;
    QString longDescription;
    int subscribers;
    int activeUsers;
    bool isNSFW;

private:
    Q_DISABLE_COPY(SubredditObjectData)
};


SubredditObject::SubredditObject() :
    d(new SubredditObjectData)
{
}

SubredditObject::SubredditObject(const SubredditObject &other) :
    d(other.d)
{
}

SubredditObject &SubredditObject::operator =(const SubredditObject &other)
{
    d = other.d;
    return *this;
}

SubredditObject::~SubredditObject()
{
}

QString SubredditObject::fullname() const
{
    return d->fullname;
}

void SubredditObject::setFullname(const QString &fullname)
{
    d->fullname = fullname;
}

QString SubredditObject::displayName() const
{
    return d->displayName;
}

void SubredditObject::setDisplayName(const QString &displayName)
{
    d->displayName = displayName;
}

QString SubredditObject::url() const
{
    return d->url;
}

void SubredditObject::setUrl(const QString &url)
{
    d->url = url;
}

QUrl SubredditObject::headerImageUrl() const
{
    return d->headerImageUrl;
}

void SubredditObject::setHeaderImageUrl(const QUrl &url)
{
    d->headerImageUrl = url;
}

QString SubredditObject::shortDescription() const
{
    return d->shortDescription;
}

void SubredditObject::setShortDescription(const QString &description)
{
    d->shortDescription = description;
}

QString SubredditObject::longDescription() const
{
    return d->longDescription;
}

void SubredditObject::setLongDescription(const QString &description)
{
    d->longDescription = description;
}

int SubredditObject::subscribers() const
{
    return d->subscribers;
}

void SubredditObject::setSubscribers(int subscribers)
{
    d->subscribers = subscribers;
}

int SubredditObject::activeUsers() const
{
    return d->activeUsers;
}

void SubredditObject::setActiveUsers(int activeUsers)
{
    d->activeUsers = activeUsers;
}

bool SubredditObject::isNSFW() const
{
    return d->isNSFW;
}

void SubredditObject::setNSFW(bool nsfw)
{
    d->isNSFW = nsfw;
}
