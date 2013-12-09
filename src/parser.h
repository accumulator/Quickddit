#ifndef PARSER_H
#define PARSER_H

#include <QtCore/QList>
#include <QtCore/QPair>
#include <QtCore/QByteArray>

class LinkObject;
class CommentObject;
class SubredditObject;

namespace Parser
{
QList<LinkObject> parseLinkList(const QByteArray &json);

QList<CommentObject> parseCommentList(const QByteArray &json);

SubredditObject parseSubreddit(const QByteArray &json);
QList<SubredditObject> parseSubredditList(const QByteArray &json);

QList< QPair<QString, QString> > parseImgurImages(const QByteArray &json);
}

#endif // PARSER_H
