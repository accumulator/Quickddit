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

#include "aboutsubredditmanager.h"

#include <QtNetwork/QNetworkReply>

#include "parser.h"

AboutSubredditManager::AboutSubredditManager(QObject *parent) :
    AbstractManager(parent), m_request(0)
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
    if (m_request != 0) {
        qWarning("AboutSubredditManager::refresh(): Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }

    QString relativeUrl = "/r/" + m_subreddit + "/about";

    m_request = manager()->createRedditRequest(this, APIRequest::GET, relativeUrl);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onFinished(QNetworkReply*)));

    setBusy(true);
}

void AboutSubredditManager::subscribeOrUnsubscribe()
{
    if (m_request != 0) {
        qWarning("AboutSubredditManager::subscribeOrUnsubscribe():"
                 "Aborting active network request (Try to avoid!)");
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }

    QHash<QString, QString> parameters;
    parameters["sr"] = m_subredditObject.fullname();
    if (m_subredditObject.isSubscribed())
        parameters["action"] = "unsub";
    else
        parameters["action"] = "sub";

    m_request = manager()->createRedditRequest(this, APIRequest::POST, "/api/subscribe", parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onSubscribeFinished(QNetworkReply*)));

    setBusy(true);
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

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
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

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}
