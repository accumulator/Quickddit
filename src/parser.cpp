#include "parser.h"

#include <QtCore/QDateTime>
#include <QtCore/QUrl>
#include <qt-json/json.h>

#include "linkobject.h"
#include "commentobject.h"
#include "subredditobject.h"

// TODO: Parse all "description" formatted in markdown to HTML(?) for display

QList<LinkObject> Parser::parseLinkList(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(QString::fromUtf8(json), ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList linkListJson = root.toMap().value("data").toMap().value("children").toList();

    QList<LinkObject> linkList;
    foreach (const QVariant &linkObjectJson, linkListJson) {
        LinkObject link;

        const QVariantMap linkMapJson = linkObjectJson.toMap().value("data").toMap();
        link.setFullname(linkMapJson.value("name").toString());
        link.setAuthor(linkMapJson.value("author").toString());
        link.setCreated(QDateTime::fromTime_t(linkMapJson.value("created_utc").toInt()));
        link.setSubreddit(linkMapJson.value("subreddit").toString());
        link.setScore(linkMapJson.value("score").toInt());
        link.setCommentsCount(linkMapJson.value("num_comments").toInt());
        link.setTitle(linkMapJson.value("title").toString());
        link.setDomain(linkMapJson.value("domain").toString());

        QString thumbnail = linkMapJson.value("thumbnail").toString();
        if (thumbnail.startsWith("http"))
            link.setThumbnailUrl(QUrl(thumbnail));
        link.setText(linkMapJson.value("selftext").toString());
        link.setPermalink(linkMapJson.value("permalink").toString());
        link.setUrl(QUrl(linkMapJson.value("url").toString()));
        link.setDistinguished(linkMapJson.value("distinguished").toString());
        link.setSticky(linkMapJson.value("stickied").toBool());
        link.setNSFW(linkMapJson.value("over_18").toBool());

        linkList.append(link);
    }

    return linkList;
}

// Private
QList<CommentObject> parseCommentListingJson(const QVariantMap &json, const QString &linkAuthor, int depth)
{
    Q_ASSERT(json.value("kind") == "Listing");

    QList<CommentObject> commentList;

    const QVariantList childrenList = json.value("data").toMap().value("children").toList();
    foreach (const QVariant &commentJson, childrenList) {
        if (commentJson.toMap().value("kind") != "t1")
            continue;

        const QVariantMap commentMap = commentJson.toMap().value("data").toMap();

        CommentObject comment;
        comment.setFullname(commentMap.value("name").toString());
        comment.setAuthor(commentMap.value("author").toString());
        comment.setBody(commentMap.value("body").toString());
        int upvotes = commentMap.value("ups").toInt();
        int downvotes = commentMap.value("downs").toInt();
        comment.setScore(upvotes - downvotes);
        comment.setCreated(QDateTime::fromTime_t(commentMap.value("created_utc").toInt()));
        if (commentMap.value("edited").toBool() != false)
            comment.setEdited(QDateTime::fromTime_t(commentMap.value("edited").toInt()));
        comment.setDistinguished(commentMap.value("distinguished").toString());
        comment.setDepth(depth);
        comment.setSubmitter(comment.author() == linkAuthor);
        comment.setScoreHidden(commentMap.value("score_hidden").toBool());

        commentList.append(comment);

        if (commentMap.value("replies").type() == QVariant::Map)
            commentList.append(parseCommentListingJson(commentMap.value("replies").toMap(), linkAuthor, depth + 1));
    }

    return commentList;
}

QList<CommentObject> Parser::parseCommentList(const QByteArray &json)
{
    bool ok;
    const QVariantList root = QtJson::parse(QString::fromUtf8(json), ok).toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    // Longest. Expression. Ever.
    const QString linkAuthor = root.first().toMap().value("data").toMap()
            .value("children").toList().first().toMap().value("data").toMap()
            .value("author").toString();

    return parseCommentListingJson(root.last().toMap(), linkAuthor, 0);
}

// Private
SubredditObject parseSubredditThing(const QVariantMap &subredditThing)
{
    Q_ASSERT(subredditThing.value("kind").toString() == "t5");

    const QVariantMap data = subredditThing.value("data").toMap();

    SubredditObject subreddit;
    subreddit.setFullname(data.value("name").toString());
    subreddit.setDisplayName(data.value("display_name").toString());
    subreddit.setUrl(data.value("url").toString());
    subreddit.setHeaderImageUrl(QUrl(data.value("header_img").toString()));
    subreddit.setShortDescription(data.value("public_description").toString());
    subreddit.setLongDescription(data.value("description").toString());
    subreddit.setSubscribers(data.value("subscribers").toInt());
    subreddit.setActiveUsers(data.value("accounts_active").toInt());
    subreddit.setNSFW(data.value("over18").toBool());
    return subreddit;
}

SubredditObject Parser::parseSubreddit(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(json, ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    return parseSubredditThing(root.toMap());
}

QList<SubredditObject> Parser::parseSubredditList(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(json, ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList subredditListJson = root.toMap().value("data").toMap().value("children").toList();

    QList<SubredditObject> subredditList;
    foreach (const QVariant &subredditJson, subredditListJson) {
        subredditList.append(parseSubredditThing(subredditJson.toMap()));
    }

    return subredditList;
}
