/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2015  Sander van Grieken

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

#include "linkmanager.h"

#include <QtNetwork/QNetworkReply>

#include "linkmodel.h"
#include "parser.h"

LinkManager::LinkManager(QObject *parent) :
    AbstractManager(parent), m_request(0), m_linkModel(0), m_commentModel(0)
{
}

LinkModel *LinkManager::linkModel() const
{
    return m_linkModel;
}

void LinkManager::setLinkModel(LinkModel *model)
{
    m_linkModel = model;
}

CommentModel *LinkManager::commentModel() const
{
    return m_commentModel;
}

void LinkManager::setCommentModel(CommentModel *model)
{
    m_commentModel = model;
}

void LinkManager::submit(const QString &subreddit, const QString &captcha, const QString &iden, const QString &title, const QString& url, const QString& text)
{
    abortActiveReply();

    m_action = Submit;

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    // captcha
    parameters.insert("captcha", captcha);
    parameters.insert("iden", iden);
    // self?
    parameters.insert("kind", url.isEmpty() ? "self" : "link");
    if (!url.isEmpty())
        parameters.insert("url", url);
    // basic
    parameters.insert("sr", subreddit);
    parameters.insert("text", text);
    parameters.insert("title", title);

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/submit", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void LinkManager::editLinkText(const QString &fullname, const QString &rawText)
{
    abortActiveReply();

    m_action = Edit;

    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("text", rawText);
    parameters.insert("thing_id", fullname);
    m_fullname = fullname;
    m_text = rawText;

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/editusertext", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}


void LinkManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            if (m_action == Submit) {
                QList<QString> errors = Parser::parseErrors(reply->readAll());
                if (errors.size() == 0) {
                    emit success(tr("The link has been added"));
                } else {
                    emit error("Error:" + errors.first());
                }
            } else {
                LinkObject link = Parser::parseLinkEditResponse(reply->readAll());
                emit success(tr("The link text has been changed"));
                // update both occurrences of a Link. Bit ugly to have to refer to two models,
                // but this way the UI never shows stale data.
                if (m_linkModel)
                    m_linkModel->editLink(link);
                if (m_commentModel)
                    m_commentModel->setLink(LinkModel::toLinkVariantMap(link));
            }
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void LinkManager::abortActiveReply()
{
    if (m_request != 0) {
        qWarning("LinkManager::abortActiveReply(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }
}
