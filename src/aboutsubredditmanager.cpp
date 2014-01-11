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
    AbstractManager(parent), m_reply(0)
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
    if (m_reply != 0) {
        qWarning("AboutSubredditManager::refresh(): Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QString relativeUrl = "/r/" + m_subreddit + "/about";

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::GET, relativeUrl);

    setBusy(true);
}

void AboutSubredditManager::subscribeOrUnsubscribe()
{
    if (m_reply != 0) {
        qWarning("AboutSubredditManager::subscribeOrUnsubscribe():"
                 "Aborting active network request (Try to avoid!)");
        m_reply->disconnect();
        m_reply->deleteLater();
        m_reply = 0;
    }

    QHash<QString, QString> parameters;
    parameters["sr"] = m_subredditObject.fullname();
    if (m_subredditObject.isSubscribed())
        parameters["action"] = "unsub";
    else
        parameters["action"] = "sub";

    connect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
            SLOT(onSubscribeNetworkReplyReceived(QNetworkReply*)));
    manager()->createRedditRequest(QuickdditManager::POST, "/api/subscribe", parameters);

    setBusy(true);
}

void AboutSubredditManager::onNetworkReplyReceived(QNetworkReply *reply)
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

void AboutSubredditManager::onFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        m_subredditObject = Parser::parseSubreddit(m_reply->readAll());
        setSubreddit(m_subredditObject.displayName());
        emit dataChanged();
    } else {
        emit error(m_reply->errorString());
    }

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}

void AboutSubredditManager::onSubscribeNetworkReplyReceived(QNetworkReply *reply)
{
    disconnect(manager(), SIGNAL(networkReplyReceived(QNetworkReply*)),
               this, SLOT(onSubscribeNetworkReplyReceived(QNetworkReply*)));
    if (reply != 0) {
        m_reply = reply;
        m_reply->setParent(this);
        connect(m_reply, SIGNAL(finished()), SLOT(onSubscribeFinished()));
    } else {
        setBusy(false);
    }
}

void AboutSubredditManager::onSubscribeFinished()
{
    if (m_reply->error() == QNetworkReply::NoError) {
        m_subredditObject.setSubscribed(!m_subredditObject.isSubscribed());
        emit dataChanged();
        emit subscribeSuccess();
    } else {
        emit error(m_reply->errorString());
    }

    m_reply->deleteLater();
    m_reply = 0;
    setBusy(false);
}
