/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

#include "savemanager.h"

SaveManager::SaveManager(QObject *parent) :
        AbstractManager(parent)
{

}

void SaveManager::unsave(const QString &fullname)
{
    save(fullname, false);
}

void SaveManager::save(const QString &fullname, bool save)
{
    m_fullname = fullname;
    m_save = save;

    QHash<QString, QString> parameters;
    parameters["id"] = m_fullname;

    doRequest(APIRequest::POST, save ? "/api/save" : "/api/unsave", SLOT(onFinished(QNetworkReply*)), parameters);
}

void SaveManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError)
            emit success(m_fullname, m_save);
        else
            emit error(reply->errorString());
    }
}
