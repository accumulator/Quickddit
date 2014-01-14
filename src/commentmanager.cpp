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

#include "commentmanager.h"

#include <QtNetwork/QNetworkReply>

#include "appsettings.h"
#include "commentmodel.h"
#include "parser.h"

CommentManager::CommentManager(QObject *parent) :
    AbstractManager(parent), m_model(0), m_reply(0)
{
}

CommentModel *CommentManager::model() const
{
    return m_model;
}

void CommentManager::setModel(CommentModel *model)
{
    m_model = model;
}

QString CommentManager::linkAuthor() const
{
    return m_linkAuthor;
}

void CommentManager::setLinkAuthor(const QString &linkAuthor)
{
    m_linkAuthor = linkAuthor;
}

void CommentManager::addComment(const QString &replyTofullname, const QString &rawText)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", replyTofullname);
    m_action = Insert;
    m_fullname = replyTofullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/comment", parameters);
}

void CommentManager::editComment(const QString &fullname, const QString &rawText)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", fullname);
    m_action = Edit;
    m_fullname = fullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/editusertext", parameters);
}

void CommentManager::deleteComment(const QString &fullname)
{
    abortActiveReply();

    QHash<QString, QString> parameters;
    parameters.insert("id", fullname);
    m_action = Delete;
    m_fullname = fullname;

    setBusy(true);

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)), SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/del", parameters);
}

void CommentManager::onNetworkReplyReceived(QNetworkReply *reply)
{
    disconnect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
               this, SLOT(onNetworkReplyReceived(QNetworkReply*)));
    if (reply != 0) {
        m_reply = reply;
        m_reply->setParent(this);
        connect(m_reply, SIGNAL(finished()), SLOT(onFinished()));
    } else {
        setBusy(false);
    }
}

void CommentManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        if (m_action == Insert || m_action == Edit) {
            CommentObject comment = Parser::parseNewComment(m_reply->readAll());
            if (m_linkAuthor == manager()->settings()->redditUsername())
                comment.setSubmitter(true);

            if (m_action == Insert)
                m_model->insertComment(comment, m_fullname);
            else
                m_model->editComment(comment);
        } else if (m_action == Delete) {
            m_model->deleteComment(m_fullname);
        }
    } else {
        emit error(m_reply->errorString());
    }

    m_fullname.clear();
    setBusy(false);
    m_reply->deleteLater();
    m_reply = 0;
}

void CommentManager::abortActiveReply()
{
    if (m_reply != 0) {
        qWarning("CommentManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }
}
