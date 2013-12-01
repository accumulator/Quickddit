#ifndef SUBREDDITOBJECT_H
#define SUBREDDITOBJECT_H

#include <QtCore/QExplicitlySharedDataPointer>

class QUrl;
class SubredditObjectData;

class SubredditObject
{
public:
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

private:
    QExplicitlySharedDataPointer<SubredditObjectData> d;
};

#endif // SUBREDDITOBJECT_H
