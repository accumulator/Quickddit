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
#include "utils.h"

AboutMultiredditManager::AboutMultiredditManager(QObject *parent) :
    AbstractManager(parent), m_model(0)
{
}

void AboutMultiredditManager::classBegin()
{
}

void AboutMultiredditManager::componentComplete()
{
    Q_ASSERT(!m_name.isEmpty());
    Q_ASSERT(m_model != 0);

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

QString AboutMultiredditManager::iconUrl() const
{
    return m_multiredditObject.iconUrl();
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
    QVariantHash variantHash;
    variantHash.insert("name", subreddit);
    QHash<QString, QString> parameters;
    parameters.insert("model", QtJson::serializeStr(variantHash));

    doRequest(APIRequest::PUT, "/api/multi" + m_multiredditObject.path() + "/r/" + subreddit, SLOT(onAddFinished(QNetworkReply*)), parameters);
}

void AboutMultiredditManager::removeSubreddit(const QString &subreddit)
{
    doRequest(APIRequest::DELETE, "/api/multi" + m_multiredditObject.path() + "/r/" + subreddit, SLOT(onRemoveFinished(QNetworkReply*)));
}

void AboutMultiredditManager::getDescription()
{
    doRequest(APIRequest::GET, "/api/multi" + m_multiredditObject.path() + "/description", SLOT(onDescriptionFinished(QNetworkReply*)));
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
}

void AboutMultiredditManager::onAddFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            const QString addedSubreddit = QtJson::parse(reply->readAll()).toMap().value("name").toString();
            if (!addedSubreddit.isEmpty()) {
                QStringList subreddits = m_multiredditObject.subreddits();
                subreddits.append(addedSubreddit);
                Utils::sortCaseInsensitively(&subreddits);
                m_multiredditObject.setSubreddits(subreddits);
                emit multiredditChanged();
                emit success(tr("%1 has been added to %2").arg("/r/" + addedSubreddit).arg("/m/" + m_name));
            }
        } else {
            emit error(reply->errorString());
        }
    }
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
            emit success(tr("%1 has been removed from %2").arg("/r/" + toBeRemoveSubreddit).arg("/m/" + m_name));
            toBeRemoveSubreddit.clear();
        } else {
            emit error(reply->errorString());
        }
    }
}
