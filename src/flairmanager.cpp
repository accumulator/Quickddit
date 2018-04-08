/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2017  Sander van Grieken

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

#include <QDebug>

#include "flairmanager.h"
#include "parser.h"

FlairManager::FlairManager(QObject *parent) : AbstractManager(parent)
{
    connect(this, SIGNAL(subredditChanged()), this, SLOT(getSubredditFlair()));
}

QString FlairManager::subreddit() const
{
    return m_subreddit;
}

void FlairManager::setSubreddit(const QString &subreddit)
{
    if (m_subreddit != subreddit) {
        m_subreddit = subreddit;
        emit subredditChanged();
    }
}

QVariantList FlairManager::subredditFlairs() const
{
    return m_subredditFlairs;
}

QVariantMap FlairManager::flairs() const
{
    return m_flairs;
}

void FlairManager::getSubredditFlair()
{
    qDebug() << "getting flair for" << m_subreddit;
    doRequest(APIRequest::GET, "/r/" + m_subreddit + "/api/link_flair", SLOT(onSubredditFlairFinished(QNetworkReply*)));
}

void FlairManager::onSubredditFlairFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            m_subredditFlairs = Parser::parseList(reply->readAll());
            emit subredditFlairsChanged();
        } else {
            qDebug() << "error" << reply->errorString();
        }
    }
}

void FlairManager::getFlairSelector(const QString &fullname)
{
    qDebug() << "getting flairselector for" << fullname;
    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    if (!fullname.isEmpty())
        parameters.insert("link", fullname);
    doRequest(APIRequest::POST, "/r/" + m_subreddit + "/api/flairselector", SLOT(onFlairSelectorFinished(QNetworkReply*)), parameters);
}

void FlairManager::onFlairSelectorFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            m_flairs = Parser::parseMap(reply->readAll());
            qDebug() << "flairselector" << m_flairs;
            emit flairsChanged();
        } else {
            qDebug() << "error" << reply->errorString();
        }
    }
}

void FlairManager::selectFlair(const QString& fullname, const QString& flairId)
{
    qDebug() << "selecting flair for" << fullname << "to" << flairId;
    QHash<QString, QString> parameters;
    parameters.insert("api_type", "json");
    parameters.insert("link", fullname);
    parameters.insert("flair_template_id", flairId);
    doRequest(APIRequest::POST, "/r/" + m_subreddit + "/api/selectflair", SLOT(onSelectFlairFinished(QNetworkReply*)), parameters);
}

void FlairManager::onSelectFlairFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            qDebug() << "select flair ok";
        } else {
            qDebug() << "error" << reply->errorString();
        }
    }
}
