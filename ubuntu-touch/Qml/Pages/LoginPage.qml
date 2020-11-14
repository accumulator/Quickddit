/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.9
import QtWebEngine 1.7
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import Qt.labs.platform 1.0

Page {
    WebEngineView{
        anchors.fill: parent
        id:loginPage
        settings.localContentCanAccessFileUrls: true
        settings.localContentCanAccessRemoteUrls: true
        profile: WebEngineProfile{
            persistentStoragePath: StandardPaths.writableLocation(StandardPaths.DataLocation).toString().substring(7)
        }

        onUrlChanged: {
            if (url.toString().indexOf("code=") > 0) {
                stop();
                quickdditManager.getAccessToken(url);
            }
        }
    }


    Connections {
        target: quickdditManager
        onAccessTokenSuccess: {
            infoBanner.alert(qsTr("Sign in successful! Welcome! :)"));
            //inboxManager.resetTimer();
            var mainPage = globalUtils.getMainPage();
            mainPage.refresh();
            pageStack.pop(mainPage);
        }
        onAccessTokenFailure: {
            infoBanner.warning(qsTr("error"));
        }
    }
    Component.onCompleted: loginPage.url = quickdditManager.generateAuthorizationUrl();
}
