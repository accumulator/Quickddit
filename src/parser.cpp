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

#include "parser.h"

#include <QtCore/QDateTime>
#include <QtCore/QUrl>
#include <QtGui/QTextDocument>
#include <qt-json/json.h>

#include "linkobject.h"
#include "commentobject.h"
#include "subredditobject.h"
#include "multiredditobject.h"
#include "messageobject.h"
#include "utils.h"

#include <QDebug>

QString unescapeHtml(const QString &html)
{
    QTextDocument document;
    document.setHtml(html);
    QString unescaped = document.toPlainText();
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

// Private
LinkObject parseLinkThing(const QVariant &linkThing)
{
    const QVariantMap linkMapJson = linkThing.toMap().value("data").toMap();

    LinkObject link;
    link.setFullname(linkMapJson.value("name").toString());
    link.setAuthor(linkMapJson.value("author").toString());
    link.setCreated(QDateTime::fromTime_t(linkMapJson.value("created_utc").toInt()));
    link.setSubreddit(linkMapJson.value("subreddit").toString());
    link.setScore(linkMapJson.value("score").toInt());
    if (!linkMapJson.value("likes").isNull())
        link.setLikes(linkMapJson.value("likes").toBool() ? 1 : -1);
    link.setCommentsCount(linkMapJson.value("num_comments").toInt());
    link.setTitle(unescapeMarkdown(linkMapJson.value("title").toString()));
    link.setDomain(linkMapJson.value("domain").toString());

    QString thumbnail = linkMapJson.value("thumbnail").toString();
    if (thumbnail.startsWith("http"))
        link.setThumbnailUrl(QUrl(thumbnail));
    link.setText(unescapeHtml(linkMapJson.value("selftext_html").toString()));
    link.setRawText(unescapeMarkdown(linkMapJson.value("selftext").toString()));
    link.setPermalink(linkMapJson.value("permalink").toString());
    link.setUrl(QUrl(linkMapJson.value("url").toString()));
    link.setDistinguished(linkMapJson.value("distinguished").toString());
    link.setSticky(linkMapJson.value("stickied").toBool());
    link.setNSFW(linkMapJson.value("over_18").toBool());
    link.setPromoted(linkMapJson.value("promoted").toBool());

    return link;
}

Listing<LinkObject> Parser::parseLinkList(const QByteArray &json)
{
    bool ok;
    const QVariantMap data = QtJson::parse(QString::fromUtf8(json), ok).toMap().value("data").toMap();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const QVariantList linkListJson = data.value("children").toList();

    Listing<LinkObject> linkList;
    foreach (const QVariant &linkObjectJson, linkListJson) {
        linkList.append(parseLinkThing(linkObjectJson));
    }
    linkList.setHasMore(!data.value("after").isNull());

    return linkList;
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
        comment.setFullname(commentMap.value("name").toString());
        comment.setDepth(depth);

        if (kind == QLatin1String("t1")) {
            comment.setAuthor(commentMap.value("author").toString());
            comment.setBody(unescapeHtml(commentMap.value("body_html").toString()));
            comment.setRawBody(unescapeMarkdown(commentMap.value("body").toString()));
            comment.setScore(commentMap.value("score").toInt());
            if (!commentMap.value("likes").isNull())
                comment.setLikes(commentMap.value("likes").toBool() ? 1 : -1);
            comment.setCreated(QDateTime::fromTime_t(commentMap.value("created_utc").toInt()));
            if (commentMap.value("edited").toBool() != false)
                comment.setEdited(QDateTime::fromTime_t(commentMap.value("edited").toInt()));
            comment.setDistinguished(commentMap.value("distinguished").toString());
            comment.setSubmitter(comment.author() == linkAuthor);
            comment.setScoreHidden(commentMap.value("score_hidden").toBool());
        } else if (kind == QLatin1String("more")) {
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

    const QVariantList childrenList = root.value("jquery").toList().last().toList().last().toList().first().toList();
    qDebug() << "children list" << childrenList;

    foreach (const QVariant &commentJson, childrenList) {
        const QString kind = commentJson.toMap().value("kind").toString();
        const QVariantMap commentMap = commentJson.toMap().value("data").toMap();

        CommentObject comment;
        comment.setFullname(commentMap.value("name").toString());
        comment.setDepth(depth);

        if (kind == QLatin1String("t1")) {
            qDebug() << "T1";
            comment.setAuthor(commentMap.value("author").toString());
            comment.setBody(unescapeHtml(commentMap.value("body_html").toString()));
            comment.setRawBody(unescapeMarkdown(commentMap.value("body").toString()));
            comment.setScore(commentMap.value("score").toInt());
            if (!commentMap.value("likes").isNull())
                comment.setLikes(commentMap.value("likes").toBool() ? 1 : -1);
            comment.setCreated(QDateTime::fromTime_t(commentMap.value("created_utc").toInt()));
            if (commentMap.value("edited").toBool() != false)
                comment.setEdited(QDateTime::fromTime_t(commentMap.value("edited").toInt()));
            comment.setDistinguished(commentMap.value("distinguished").toString());
            comment.setSubmitter(comment.author() == linkAuthor);
            comment.setScoreHidden(commentMap.value("score_hidden").toBool());
        } else if (kind == QLatin1String("more")) {
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

//        if (commentMap.value("replies").type() == QVariant::Map)
//            commentList.append(parseCommentListingJson(commentMap.value("replies").toMap(), linkAuthor, depth + 1));
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
    comment.setFullname(commentMap.value("name").toString());
    comment.setAuthor(commentMap.value("author").toString());
    comment.setBody(unescapeHtml(commentMap.value("body_html").toString()));
    comment.setRawBody(unescapeMarkdown(commentMap.value("body").toString()));
    comment.setScore(commentMap.value("score").toInt());
    if (!commentMap.value("likes").isNull())
        comment.setLikes(commentMap.value("likes").toBool() ? 1 : -1);
    comment.setCreated(QDateTime::fromTime_t(commentMap.value("created_utc").toInt()));
    if (commentMap.value("edited").toBool() != false)
        comment.setEdited(QDateTime::fromTime_t(commentMap.value("edited").toInt()));
    comment.setDistinguished(commentMap.value("distinguished").toString());
    comment.setScoreHidden(commentMap.value("score_hidden").toBool());

    return comment;
}

QPair< LinkObject, QList<CommentObject> > Parser::parseCommentList(const QByteArray &json)
{
    bool ok;
    const QVariantList root = QtJson::parse(QString::fromUtf8(json), ok).toList();

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

    const LinkObject link = parseLinkThing(root.first().toMap().value("data").toMap()
                                           .value("children").toList().first());

    return qMakePair(link, parseCommentListingJson(root.last().toMap(), link.author(), 0));
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
    subreddit.setLongDescription(unescapeHtml(data.value("description_html").toString()));
    subreddit.setSubscribers(data.value("subscribers").toInt());
    subreddit.setActiveUsers(data.value("accounts_active").toInt());
    subreddit.setNSFW(data.value("over18").toBool());
    subreddit.setSubscribed(data.value("user_is_subscriber").toBool());
    return subreddit;
}

SubredditObject Parser::parseSubreddit(const QByteArray &json)
{
    bool ok;
    const QVariant root = QtJson::parse(json, ok);

    Q_ASSERT_X(ok, Q_FUNC_INFO, "Error parsing JSON");

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
        multireddit.setName(multiredditMap.value("name").toString());
        multireddit.setCreated(QDateTime::fromTime_t(multiredditMap.value("created_utc").toInt()));

        QStringList subreddits;
        foreach (const QVariant &subredditObj, multiredditMap.value("subreddits").toList()) {
            subreddits.append(subredditObj.toMap().value("name").toString());
        }
        Utils::sortCaseInsensitively(&subreddits);

        multireddit.setSubreddits(subreddits);
        multireddit.setVisibility(multiredditMap.value("visibility").toString());
        multireddit.setPath(multiredditMap.value("path").toString());
        multireddit.setCanEdit(multiredditMap.value("can_edit").toBool());

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
    foreach (const QVariant &messageObject, messagesJson) {
        const QVariantMap messageMap = messageObject.toMap().value("data").toMap();

        MessageObject message;
        message.setFullname(messageMap.value("name").toString());
        message.setAuthor(messageMap.value("author").toString());
        message.setDestination(messageMap.value("dest").toString());
        message.setBody(unescapeHtml(messageMap.value("body_html").toString()));
        message.setCreated(QDateTime::fromTime_t(messageMap.value("created_utc").toInt()));
        message.setSubject(messageMap.value("subject").toString());
        message.setLinkTitle(messageMap.value("link_title").toString());
        message.setSubreddit(messageMap.value("subreddit").toString());
        message.setContext(messageMap.value("context").toString());
        message.setComment(messageMap.value("was_comment").toBool());
        message.setUnread(messageMap.value("new").toBool());

        messageList.append(message);
    }
    messageList.setHasMore(!data.value("after").isNull());

    return messageList;
}

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
