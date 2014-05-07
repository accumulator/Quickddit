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

#include "aboutmultiredditmanager.h"

#include <QtNetwork/QNetworkReply>
#include <qt-json/json.h>
#include "multiredditmodel.h"
#include "parser.h"

AboutMultiredditManager::AboutMultiredditManager(QObject *parent) :
    AbstractManager(parent), m_model(0), m_request(0)
{
}

void AboutMultiredditManager::classBegin()
{
}

void AboutMultiredditManager::componentComplete()
{
    Q_ASSERT(!m_name.isEmpty() && m_model != 0);

    m_multiredditObject = m_model->getMultireddit(m_name);
    emit multiredditChanged();

    if (m_multiredditObject.description().isEmpty())
        getDescription();
}

QString AboutMultiredditManager::name() const
{
    return m_name;
}

void AboutMultiredditManager::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

QString AboutMultiredditManager::description() const
{
    return m_multiredditObject.description();
}

QStringList AboutMultiredditManager::subreddits() const
{
    return m_multiredditObject.subreddits();
}

bool AboutMultiredditManager::canEdit() const
{
    return m_multiredditObject.canEdit();
}

MultiredditModel *AboutMultiredditManager::model() const
{
    return m_model;
}

void AboutMultiredditManager::setModel(MultiredditModel *model)
{
    m_model = model;
}

void AboutMultiredditManager::addSubreddit(const QString &subreddit)
{
    abortActiveRequest();

    QString url = "/api/multi" + m_multiredditObject.path() + "/r/" + subreddit;

    QVariantHash variantHash;
    variantHash.insert("name", subreddit);
    QHash<QString, QString> parameters;
    parameters.insert("model", QtJson::serializeStr(variantHash));

    m_request = manager()->createRedditRequest(this, APIRequest::PUT, url, parameters);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onAddFinished(QNetworkReply*)));

    setBusy(true);
}

void AboutMultiredditManager::removeSubreddit(const QString &subreddit)
{
    abortActiveRequest();

    toBeRemoveSubreddit = subreddit;
    QString url = "/api/multi" + m_multiredditObject.path() + "/r/" + subreddit;
    m_request = manager()->createRedditRequest(this, APIRequest::DELETE, url);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onRemoveFinished(QNetworkReply*)));

    setBusy(true);
}

void AboutMultiredditManager::getDescription()
{
    abortActiveRequest();

    QString url = "/api/multi" + m_multiredditObject.path() + "/description";
    m_request = manager()->createRedditRequest(this, APIRequest::GET, url);
    connect(m_request, SIGNAL(finished(QNetworkReply*)), SLOT(onDescriptionFinished(QNetworkReply*)));

    setBusy(true);
}

void AboutMultiredditManager::onDescriptionFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            m_multiredditObject.setDescription(Parser::parseMultiredditDescription(reply->readAll()));
            emit multiredditChanged();
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void AboutMultiredditManager::onAddFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const QString addedSubreddit = QtJson::parse(reply->readAll()).toMap().value("name").toString();
            if (!addedSubreddit.isEmpty()) {
                QStringList subreddits = m_multiredditObject.subreddits();
                subreddits.append(addedSubreddit);
                m_multiredditObject.setSubreddits(subreddits);
                emit multiredditChanged();
                emit success("/r/" + addedSubreddit + " has been added to /m/" + m_name);
            }
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void AboutMultiredditManager::onRemoveFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            QStringList subreddits = m_multiredditObject.subreddits();
            for (int i = 0; i < subreddits.count(); ++i) {
                if (subreddits.at(i) == toBeRemoveSubreddit) {
                    subreddits.removeAt(i);
                    break;
                }
            }
            m_multiredditObject.setSubreddits(subreddits);
            emit multiredditChanged();
            emit success("/r/" + toBeRemoveSubreddit + " has been removed from /m/" + m_name);
            toBeRemoveSubreddit.clear();
        } else {
            emit error(reply->errorString());
        }
    }

    m_request->deleteLater();
    m_request = 0;
    setBusy(false);
}

void AboutMultiredditManager::abortActiveRequest()
{
    if (m_request != 0) {
        m_request->disconnect();
        m_request->deleteLater();
        m_request = 0;
    }
}
