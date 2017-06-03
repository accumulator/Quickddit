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

#include <QtNetwork/QNetworkReply>

#include "aboutsubredditmanager.h"
#include "parser.h"

AboutSubredditManager::AboutSubredditManager(QObject *parent) :
    AbstractManager(parent)
{
}

void AboutSubredditManager::classBegin()
{
}

void AboutSubredditManager::componentComplete()
{
    Q_ASSERT(!m_subreddit.isEmpty());
    refresh();
}

bool AboutSubredditManager::isValid() const
{
    return !m_subredditObject.fullname().isEmpty();
}

QString AboutSubredditManager::url() const
{
    return m_subredditObject.url();
}

QUrl AboutSubredditManager::headerImageUrl() const
{
    return m_subredditObject.headerImageUrl();
}

QString AboutSubredditManager::shortDescription() const
{
    return m_subredditObject.shortDescription();
}

QString AboutSubredditManager::longDescription() const
{
    return m_subredditObject.longDescription();
}

int AboutSubredditManager::subscribers() const
{
    return m_subredditObject.subscribers();
}

int AboutSubredditManager::activeUsers() const
{
    return m_subredditObject.activeUsers();
}

bool AboutSubredditManager::isNSFW() const
{
    return m_subredditObject.isNSFW();
}

bool AboutSubredditManager::isSubscribed() const
{
    return m_subredditObject.isSubscribed();
}

AboutSubredditManager::SubmissionType AboutSubredditManager::submissionType() const
{
    switch (m_subredditObject.submissionType()) {
    case Any: return Any;
    case Link: return Link;
    case Self: return Self;
    }
    return Any;
}

bool AboutSubredditManager::isContributor() const
{
    return m_subredditObject.isContributor();
}

bool AboutSubredditManager::isBanned() const
{
    return m_subredditObject.isBanned();
}

bool AboutSubredditManager::isModerator() const
{
    return m_subredditObject.isModerator();
}

bool AboutSubredditManager::isMuted() const
{
    return m_subredditObject.isMuted();
}

AboutSubredditManager::SubredditType AboutSubredditManager::subredditType() const
{
    switch (m_subredditObject.subredditType()) {
    case Public: return Public;
    case Private: return Private;
    case Restricted: return Restricted;
    case GoldRestricted: return GoldRestricted;
    case Archived: return Archived;
    }
    return Public;
}

QString AboutSubredditManager::subreddit() const
{
    return m_subreddit;
}

void AboutSubredditManager::setSubreddit(const QString &subreddit)
{
    if (m_subreddit != subreddit) {
        m_subreddit = subreddit;
        emit subredditChanged();
    }
}

void AboutSubredditManager::refresh()
{
    doRequest(APIRequest::GET, "/r/" + m_subreddit + "/about", SLOT(onFinished(QNetworkReply*)));
}

void AboutSubredditManager::subscribeOrUnsubscribe()
{
    QHash<QString, QString> parameters;
    parameters["sr"] = m_subredditObject.fullname();
    if (m_subredditObject.isSubscribed())
        parameters["action"] = "unsub";
    else
        parameters["action"] = "sub";

    doRequest(APIRequest::POST, "/api/subscribe", SLOT(onSubscribeFinished(QNetworkReply*)), parameters);
}

void AboutSubredditManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            m_subredditObject = Parser::parseSubreddit(reply->readAll());
            setSubreddit(m_subredditObject.displayName());
            emit dataChanged();
        } else {
            emit error(reply->errorString());
        }
    }
}

void AboutSubredditManager::onSubscribeFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            m_subredditObject.setSubscribed(!m_subredditObject.isSubscribed());
            emit dataChanged();
            emit subscribeSuccess();
        } else {
            emit error(reply->errorString());
        }
    }
}
