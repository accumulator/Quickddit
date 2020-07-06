/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2020  Sander van Grieken

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

#include "parser.h"

#include <QtCore/QDateTime>
#include <QtCore/QUrl>
#include <QtGui/QTextDocument>
#include <qt-json/json.h>
#include <QDebug>

#include "linkobject.h"
#include "commentobject.h"
#include "subredditobject.h"
#include "multiredditobject.h"
#include "messageobject.h"
#include "userobject.h"
#include "utils.h"

QString unescapeHtml(const QString &html)
{
    // preserve newlines in html-quoted html, otherwise they will get lost upon .toPlainText() call
    // which is problematic when <pre> preformatted text is present.
    // 1. before html unescape: "\n" -> "&lt;&gt;"
    // 2. after html unescape: "<>" -> "\n"
    // TODO: indentation in preformatted text is still an issue (and even more expensive to correct)
    QString unescaped;
    QTextDocument document;
    // as the deep-copy and replace might be expensive, only take the effort when
    // a <pre> tag is present
    if (html.contains("&lt;pre&gt;")) {
        QString shieldedHtml(html);
        shieldedHtml.replace("\n", "&lt;&gt;");
        shieldedHtml.replace(" ", "&nbsp;");
        document.setHtml(shieldedHtml);
        unescaped = document.toPlainText();
        unescaped.replace("<>", "\n");
    } else {
        document.setHtml(html);
        unescaped = document.toPlainText();
    }

    unescaped.remove("<!-- SC_OFF -->").remove("<!-- SC_ON -->");
    unescaped.remove("<div class=\"md\">").remove("</div>");
    return unescaped;
}

// reddit escape '<', '>' and '&' to '&lt;', '&gt;' and '&amp;' respectively for raw markdown text and link title
QString unescapeMarkdown(QString markdown)
{
    markdown.replace("&lt;", "<");
    markdown.replace("&gt;", ">");
    markdown.replace("&amp;", "&");
    return markdown;
}

QString unescapeUrl(QString url)
{
    url.replace("&amp;", "&");
    return url;
}

//
// field mappers
//

void commentFromMap(CommentObject &comment, const QVariantMap &commentMap)
{
    comment.setFullname(commentMap.value("name").toString());
    comment.setAuthor(commentMap.value("author").toString());
    comment.setBody(unescapeHtml(commentMap.value("body_html").toString()));
    comment.setRawBody(unescapeMarkdown(commentMap.value("body").toString()));
    comment.setScore(commentMap.value("score").toInt());
    if (!commentMap.value("likes").isNull())
        comment.setLikes(commentMap.value("likes").toBool() ? 1 : -1);
    comment.setCreated(QDateTime::fromTime_t(commentMap.value("created_utc").toUInt()));
    if (commentMap.value("edited").toBool() != false)
        comment.setEdited(QDateTime::fromTime_t(commentMap.value("edited").toUInt()));
    comment.setDistinguished(commentMap.value("distinguished").toString());
    comment.setScoreHidden(commentMap.value("score_hidden").toBool());
    comment.setSubreddit(commentMap.value("subreddit").toString());
    comment.setLinkTitle(unescapeHtml(commentMap.value("link_title").toString()));
    comment.setLinkId(commentMap.value("link_id").toString().mid(3));
    comment.setArchived(commentMap.value("archived").toBool());
    comment.setStickied(commentMap.value("stickied").toBool());
    comment.setGilded(commentMap.value("gilded").toInt());
    comment.setSaved(commentMap.value("saved").toBool());
    comment.setAuthorFlairText(unescapeHtml(commentMap.value("author_flair_text").toString()));
}

void linkFromMap(LinkObject &link, const QVariantMap &linkMap)
{
    link.setFullname(linkMap.value("name").toString());
    link.setAuthor(linkMap.value("author").toString());
    link.setCreated(QDateTime::fromTime_t(linkMap.value("created_utc").toUInt()));
    link.setSubreddit(linkMap.value("subreddit").toString());
    link.setScore(linkMap.value("score").toInt());
    if (!linkMap.value("likes").isNull())
        link.setLikes(linkMap.value("likes").toBool() ? 1 : -1);
    link.setCommentsCount(linkMap.value("num_comments").toInt());
    link.setTitle(unescapeMarkdown(linkMap.value("title").toString()));
    link.setDomain(linkMap.value("domain").toString());

    QString thumbnail = linkMap.value("thumbnail").toString();
    if (thumbnail.startsWith("http"))
        link.setThumbnailUrl(QUrl(thumbnail));
    link.setText(unescapeHtml(linkMap.value("selftext_html").toString()));
    link.setRawText(unescapeMarkdown(linkMap.value("selftext").toString()));
    link.setPermalink(linkMap.value("permalink").toString());
    link.setUrl(QUrl(unescapeUrl(linkMap.value("url").toString())));
    link.setDistinguished(linkMap.value("distinguished").toString());
    link.setSticky(linkMap.value("stickied").toBool());
    link.setNSFW(linkMap.value("over_18").toBool());
    link.setPromoted(linkMap.value("promoted").toBool());
    link.setFlairText(unescapeHtml(linkMap.value("link_flair_text").toString()));
    link.setArchived(linkMap.value("archived").toBool());
    link.setGilded(linkMap.value("gilded").toBool());
    link.setSaved(linkMap.value("saved").toBool());
    link.setLocked(linkMap.value("locked").toBool());
    link.setCrossposts(linkMap.value("num_crossposts").toInt());

    QVariantList l = linkMap.value("preview").toMap().value("images").toList();
    if(!l.isEmpty()){
        QVariantList k=l[0].toMap().value("resolutions").toList();
        if(!k.isEmpty()){
            QVariantMap j=k.last().toMap();
            link.setPreviewUrl(unescapeUrl(j.value("url").toString()));
            link.setPreviewWidth(j.value("width").toInt());
            link.setPreviewHeight(j.value("height").toInt());
        }
    }
}

void messageFromMap(MessageObject &message, const QVariantMap &messageMap)
{
    message.setFullname(messageMap.value("name").toString());
    message.setAuthor(messageMap.value("author").toString());
    message.setDestination(messageMap.value("dest").toString());
    message.setBody(unescapeHtml(messageMap.value("body_html").toString()));
    message.setRawBody(unescapeMarkdown(messageMap.value("body").toString()));
    message.setCreated(QDateTime::fromTime_t(messageMap.value("created_utc").toUInt()));
    message.setSubject(unescapeHtml(messageMap.value("subject").toString()));
    message.setLinkTitle(unescapeHtml(messageMap.value("link_title").toString()));
    message.setSubreddit(messageMap.value("subreddit").toString());
    message.setContext(messageMap.value("context").toString());
    message.setComment(messageMap.value("was_comment").toBool());
    message.setUnread(messageMap.value("new").toBool());
    message.setDistinguished(messageMap.value("distinguished").toString());
}

void multiredditFromMap(MultiredditObject &multireddit, const QVariantMap &multiredditMap)
{
    multireddit.setName(multiredditMap.value("name").toString());
    multireddit.setCreated(QDateTime::fromTime_t(multiredditMap.value("created_utc").toUInt()));

    QStringList subreddits;
    foreach (const QVariant &subredditObj, multiredditMap.value("subreddits").toList()) {
        subreddits.append(subredditObj.toMap().value("name").toString());
    }
    Utils::sortCaseInsensitively(&subreddits);

    multireddit.setSubreddits(subreddits);
    multireddit.setDescription(unescapeHtml(multiredditMap.value("description_html").toString()));
    multireddit.setIconUrl(multiredditMap.value("icon_url").toString());
    multireddit.setVisibility(multiredditMap.value("visibility").toString());
    multireddit.setPath(multiredditMap.value("path").toString());
    multireddit.setCanEdit(multiredditMap.value("can_edit").toBool());
}

SubredditObject parseSubredditThing(const QVariantMap &subredditThing)
{
    Q_ASSERT(subredditThing.value("kind").toString() == "t5");

    const QVariantMap data = subredditThing.value("data").toMap();

    SubredditObject subreddit;
    subreddit.setFullname(data.value("name").toString());
    subreddit.setDisplayName(data.value("display_name").toString());
    subreddit.setTitle(unescapeMarkdown(data.value("title").toString()));
    subreddit.setUrl(data.value("url").toString());
    subreddit.setHeaderImageUrl(QUrl(unescapeUrl(data.value("header_img").toString())));
    if(!data.value("icon_img").toString().isEmpty())
        subreddit.setIconUrl(QUrl(unescapeUrl(data.value("icon_img").toString())));
    else
        subreddit.setIconUrl(QUrl(unescapeUrl(data.value("community_icon").toString())));
    subreddit.setBannerBackgroundUrl(QUrl(unescapeUrl(data.value("banner_background_image").toString())));
    subreddit.setShortDescription(unescapeHtml(data.value("public_description").toString()));
    subreddit.setLongDescription(unescapeHtml(data.value("description_html").toString()));
    subreddit.setSubscribers(data.value("subscribers").toInt());
    subreddit.setActiveUsers(data.value("accounts_active").toInt());
    subreddit.setNSFW(data.value("over18").toBool());
    subreddit.setSubscribed(data.value("user_is_subscriber").toBool());
    subreddit.setSubmissionType(data.value("submission_type").toString());
    subreddit.setContributor(data.value("user_is_contributor").toBool());
    subreddit.setBanned(data.value("user_is_banned").toBool());
    subreddit.setModerator(data.value("user_is_moderator").toBool());
    subreddit.setMuted(data.value("user_is_muted").toBool());
    subreddit.setSubredditType(data.value("subreddit_type").toString());

    return subreddit;
}

void userobjectFromMap(UserObject &userObject, const QVariantMap &userObjectMap)
{
    userObject.setName(userObjectMap.value("name").toString());
    userObject.setLinkKarma(userObjectMap.value("link_karma").toInt());
    userObject.setCommentKarma(userObjectMap.value("comment_karma").toInt());
    QDateTime d;
    d.setTime_t(userObjectMap.value("created").toUInt());
    userObject.setCreated(d);
    userObject.setFriend(userObjectMap.value("is_friend").toBool());
    userObject.setHideFromRobots(userObjectMap.value("hide_from_robots").toBool());
    userObject.setMod(userObjectMap.value("is_mod").toBool());
    userObject.setVerifiedEmail(userObjectMap.value("has_verified_email").toBool());
    userObject.setId(userObjectMap.value("id").toString());
    userObject.setGold(userObjectMap.value("is_gold").toBool());
    userObject.setIconImg(QUrl(unescapeUrl(userObjectMap.value("icon_img").toString())));
}

//
// JSON parsers and list(ing) wrappers
//

QVariantList Parser::parseList(const QByteArray &json)
{
    qDebug() << "list:" << json;

    bool ok;
    const QVariantList variantList = QtJson::parse(json, ok).toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    return variantList;
}

QVariantMap Parser::parseMap(const QByteArray &json)
{
    qDebug() << "map:" << json;

    bool ok;
    const QVariantMap variantMap = QtJson::parse(json, ok).toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    return variantMap;
}

Listing<LinkObject> Parser::parseLinkList(const QByteArray &json)
{
    bool ok;
    const QVariantMap data = QtJson::parse(QString::fromUtf8(json), ok).toMap().value("data").toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList linkListJson = data.value("children").toList();

    Listing<LinkObject> linkList;
    foreach (const QVariant &linkObjectJson, linkListJson) {
        QVariantMap linkMap = linkObjectJson.toMap().value("data").toMap();

        LinkObject link;
        linkFromMap(link, linkMap);
        linkList.append(link);
    }
    linkList.setHasMore(!data.value("after").isNull());

    return linkList;
}

LinkObject Parser::parseLinkEditResponse(const QByteArray &json)
{
    bool ok;
    const QVariantMap root = QtJson::parse(QString::fromUtf8(json), ok).toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariant linkObjectJson = root.value("json").toMap().value("data").toMap()
            .value("things").toList().first();

    QVariantMap linkMap = linkObjectJson.toMap().value("data").toMap();
    LinkObject link;
    linkFromMap(link, linkMap);

    return link;
}


// Private
QList<CommentObject> parseCommentListingJson(const QVariantMap &json, const QString &linkAuthor, int depth)
{
    Q_ASSERT(json.value("kind") == "Listing");

    QList<CommentObject> commentList;

    const QVariantList childrenList = json.value("data").toMap().value("children").toList();

    foreach (const QVariant &commentJson, childrenList) {
        const QString kind = commentJson.toMap().value("kind").toString();
        const QVariantMap commentMap = commentJson.toMap().value("data").toMap();

        CommentObject comment;
        comment.setDepth(depth);

        if (kind == QLatin1String("t1")) {
            commentFromMap(comment, commentMap);
            comment.setSubmitter(comment.author() == linkAuthor && linkAuthor != "[deleted]");
        } else if (kind == QLatin1String("more")) {
            comment.setFullname(commentMap.value("name").toString());
            comment.setMoreChildrenCount(commentMap.value("count").toInt());
            if (commentMap.value("count").toInt() == 0)
                comment.setFullname(commentMap.value("parent_id").toString());
            else
                comment.setMoreChildren(commentMap.value("children").toStringList());
            comment.setIsMoreChildren(true);
        } else {
            qCritical("Parser::parseCommentListingJson(): Invalid kind: %s", qPrintable(kind));
            continue;
        }

        commentList.append(comment);

        if (commentMap.value("replies").type() == QVariant::Map)
            commentList.append(parseCommentListingJson(commentMap.value("replies").toMap(), linkAuthor, depth + 1));
    }

    return commentList;
}

QList<CommentObject> Parser::parseMoreChildren(const QByteArray &json, const QString &linkAuthor, int depth)
{
    bool ok;
    const QVariantMap root = QtJson::parse(QString::fromUtf8(json), ok).toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    QList<CommentObject> commentList;

    const QVariantList commentsListNode = root.value("jquery").toList().at(10).toList();
    const QVariantList childrenList = commentsListNode.last().toList().first().toList();

    foreach (const QVariant &commentJson, childrenList) {
        const QString kind = commentJson.toMap().value("kind").toString();
        const QVariantMap commentMap = commentJson.toMap().value("data").toMap();

        CommentObject comment;
        comment.setDepth(depth);

        if (kind == QLatin1String("t1")) {
            commentFromMap(comment, commentMap);
            comment.setSubmitter(comment.author() == linkAuthor && linkAuthor != "[deleted]");
        } else if (kind == QLatin1String("more")) {
            comment.setFullname(commentMap.value("name").toString());
            comment.setMoreChildrenCount(commentMap.value("count").toInt());
            if (commentMap.value("count").toInt() == 0)
                comment.setFullname(commentMap.value("parent_id").toString());
            else
                comment.setMoreChildren(commentMap.value("children").toStringList());
            comment.setIsMoreChildren(true);
        } else {
            qCritical("Parser::parseCommentListingJson(): Invalid kind: %s", qPrintable(kind));
            continue;
        }

        foreach(CommentObject commentObject, commentList) {
            if (commentObject.fullname() == commentMap.value("parent_id")) {
                comment.setDepth(commentObject.depth() + 1);
            }
        }

        commentList.append(comment);
    }

    return commentList;
}

CommentObject Parser::parseNewComment(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(QString::fromUtf8(json), ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantMap commentMap = root.toMap().value("json").toMap().value("data").toMap()
            .value("things").toList().first().toMap().value("data").toMap();

    CommentObject comment;
    commentFromMap(comment, commentMap);

    return comment;
}

QPair< LinkObject, QList<CommentObject> > Parser::parseCommentList(const QByteArray &json)
{
    bool ok;
    const QVariantList root = QtJson::parse(QString::fromUtf8(json), ok).toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    QVariant linkObjectJson = root.first().toMap().value("data").toMap()
                                           .value("children").toList().first();

    QVariantMap linkMap = linkObjectJson.toMap().value("data").toMap();
    LinkObject link;
    linkFromMap(link, linkMap);

    return qMakePair(link, parseCommentListingJson(root.last().toMap(), link.author(), 0));
}

SubredditObject Parser::parseSubreddit(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(json, ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    qDebug() << "About" << root;

    return parseSubredditThing(root.toMap());
}

Listing<SubredditObject> Parser::parseSubredditList(const QByteArray &json)
{
    bool ok;
    const QVariantMap data = QtJson::parse(json, ok).toMap().value("data").toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList subredditListJson = data.value("children").toList();

    Listing<SubredditObject> subredditList;
    foreach (const QVariant &subredditJson, subredditListJson) {
        subredditList.append(parseSubredditThing(subredditJson.toMap()));
    }
    subredditList.setHasMore(!data.value("after").isNull());

    return subredditList;
}

QList<MultiredditObject> Parser::parseMultiredditList(const QByteArray &json)
{
    bool ok;
    const QVariantList list = QtJson::parse(json, ok).toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    QList<MultiredditObject> multredditList;
    foreach (const QVariant multiredditJson, list) {
        const QVariantMap multiredditMap = multiredditJson.toMap().value("data").toMap();

        MultiredditObject multireddit;
        multiredditFromMap(multireddit, multiredditMap);
        multredditList.append(multireddit);
    }

    return multredditList;
}

QString Parser::parseMultiredditDescription(const QByteArray &json)
{
    bool ok;
    const QVariantMap map = QtJson::parse(json, ok).toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    return unescapeHtml(map.value("data").toMap().value("body_html").toString());
}

Listing<MessageObject> Parser::parseMessageList(const QByteArray &json)
{
    bool ok;
    const QVariantMap data = QtJson::parse(json, ok).toMap().value("data").toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList messagesJson = data.value("children").toList();

    Listing<MessageObject> messageList;
    foreach (const QVariant &messageJson, messagesJson) {
        const QVariantMap messageMap = messageJson.toMap().value("data").toMap();

        MessageObject message;
        messageFromMap(message, messageMap);
        messageList.append(message);
    }
    messageList.setHasMore(!data.value("after").isNull());

    return messageList;
}

QList<QString> Parser::parseErrors(const QByteArray &json)
{
    bool ok;
    const QVariantList errors = QtJson::parse(json, ok).toMap().value("json").toMap().value("errors").toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    QList<QString> result;

    foreach(const QVariant &error, errors) {
        // only add the error code for now
        result.append(error.toList().first().toString());
    }

    return result;
}

UserObject Parser::parseUserAbout(const QByteArray &json)
{
    bool ok;
    const QVariantMap userObjectMap = QtJson::parse(json, ok).toMap().value("data").toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    UserObject userObject;
    userobjectFromMap(userObject, userObjectMap);

    return userObject;
}

QStringList Parser::parseListOfNames(const QByteArray &json)
{
    bool ok;
    const QVariantList list = QtJson::parse(json, ok).toMap().value("data").toMap().value("children").toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    QStringList userList;
    foreach (const QVariant userJson, list) {
        const QVariantMap data = userJson.toMap();
        userList.append(data.value("name").toString());
    }

    return userList;
}

Listing<Thing*> Parser::parseUserThingList(const QByteArray &json)
{
    bool ok;
    const QVariantMap data = QtJson::parse(json, ok).toMap().value("data").toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList thingsJson = data.value("children").toList();

    Listing<Thing*> thingList;
    foreach (const QVariant &thing, thingsJson) {
        const QVariantMap thingMap = thing.toMap();
        const QVariantMap thingData = thingMap.value("data").toMap();

        if (thingMap.value("kind").toString() == "t1") {
            CommentObject* comment = new CommentObject;
            commentFromMap(*comment, thingData);
            thingList.append(comment);
        }
        else if (thingMap.value("kind").toString() == "t3") {
            LinkObject* link = new LinkObject;
            linkFromMap(*link, thingData);
            thingList.append(link);
        }
        else
            qDebug() << "noncomment:" << thingMap;
    }

    thingList.setHasMore(!data.value("after").isNull());

    return thingList;
}

Listing<LinkObject> Parser::parseDuplicateList(const QByteArray &json)
{
    bool ok;
    const QVariantList result = QtJson::parse(json, ok).toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");
    Q_ASSERT_X(result.count() == 2, Q_FUNC_INFO, "Expecting size 2");

    Listing<LinkObject> duplicatesList;

    const QVariantMap linkListingJson = result.at(1).toMap().value("data").toMap();

    foreach (const QVariant &linkJson, linkListingJson.value("children").toList()) {
        const QVariantMap linkMap = linkJson.toMap();
        LinkObject link;
        linkFromMap(link, linkMap);
        duplicatesList.append(link);
    }

    duplicatesList.setHasMore(!linkListingJson.value("after").isNull());

    return duplicatesList;
}

//
// non-reddit. TODO: split off to separate source file
//

// Private
QPair<QString, QString> parseImgurImageMap(const QVariantMap &imageMap)
{
    const QString imageUrl = imageMap.value("link").toString();
    int insertThumbIndex = imageUrl.lastIndexOf('.');

    QString mainUrl;
    if (imageMap.value("animated").toBool())
        mainUrl = imageUrl;
    else
        mainUrl = QString(imageUrl).insert(insertThumbIndex, 'h');

    QString thumbUrl = QString(imageUrl).insert(insertThumbIndex, 'b');

    return qMakePair(mainUrl, thumbUrl);
}

QList< QPair<QString, QString> > Parser::parseImgurImages(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(json, ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    QList< QPair<QString, QString> > imageAndThumbUrlList;

    const QVariant data = root.toMap().value("data");

    if (data.type() == QVariant::Map) {
        const QVariantMap dataMap = data.toMap();
        if (dataMap.contains("images")) {
            foreach (const QVariant &imageJson, dataMap.value("images").toList()) {
                imageAndThumbUrlList.append(parseImgurImageMap(imageJson.toMap()));
            }
        } else {
            imageAndThumbUrlList.append(parseImgurImageMap(dataMap));
        }
    } else if (data.type() == QVariant::List) {
        foreach (const QVariant &imageJson, data.toList()) {
            imageAndThumbUrlList.append(parseImgurImageMap(imageJson.toMap()));
        }
    } else {
        qCritical("Parser::parseImgurImages(): Invalid JSON");
    }

    return imageAndThumbUrlList;
}
