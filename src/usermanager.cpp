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

#include <QtNetwork/QNetworkReply>

#include "usermanager.h"
#include "parser.h"
#include "utils.h"

UserManager::UserManager(QObject *parent) :
    AbstractManager(parent)
{
}

void UserManager::request(const QString &username)
{
    doRequest(APIRequest::GET, "/user/" + username + "/about", SLOT(onFinished(QNetworkReply*)));
}

void UserManager::onFinished(QNetworkReply *reply)
{
    if (reply != 0) {
        if (reply->error() == QNetworkReply::NoError) {
            UserObject user = Parser::parseUserAbout(reply->readAll());
            m_user = toLinkVariantMap(user);
            emit success();
        } else
            emit error(reply->errorString());
    }
}

QVariantMap UserManager::user() {
    return m_user;
}

QVariantMap UserManager::toLinkVariantMap(const UserObject &user)
{
    QVariantMap map;
    map["name"] = user.name();
    map["id"] = user.id();
    map["created"] = Utils::getTimeDiff(user.created());
    map["commentKarma"] = user.commentKarma();
    map["linkKarma"] = user.linkKarma();
    map["isGold"] = user.isGold();
    map["isMod"] = user.isMod();
    map["isHideFromRobots"] = user.isHideFromRobots();
    map["hasVerifiedEmail"] = user.hasVerifiedEmail();
    map["isFriend"] = user.isFriend();
    map["iconImg"] = user.iconImg();
    return map;
}
