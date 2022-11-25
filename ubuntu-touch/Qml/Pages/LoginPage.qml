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
import QtQuick.Controls.Suru 2.2
import quickddit.Core 1.0
import "../"

Page {

    function getButtons(){
        return toolButtons
    }

    Component {
        id: toolButtons
        Row {
            ActionButton {
                id:del
                ico: "qrc:/Icons/reload.svg"
                size: Suru.units.gu(3)
                color: Suru.color(Suru.White,1)
                onClicked: {
                    loginPage.reload();
                }
            }
        }
    }

    WebEngineView {
        anchors.fill: parent
        id:loginPage
        zoomFactor: Suru.units.dp(1.0)
        profile: WebEngineProfile {
            offTheRecord: false
            storageName: "Default"
            persistentStoragePath: StandardPaths.writableLocation(StandardPaths.DataLocation).toString().substring(7)
        }

        onUrlChanged: {
            if (url.toString().indexOf("code=") > 0) {
                stop();
                quickdditManager.getAccessToken(url);
            }
        }
    }

    Dialog {
        id:loginDialog
        title: qsTr("Login issue")
        standardButtons: Dialog.Close

        anchors.centerIn: parent

        Label {
            width: parent.width
            text: qsTr("If you are unable to login, \nplease click reload button at the top right corner")
        }
    }

    Component.onCompleted: {
        loginPage.url = quickdditManager.generateAuthorizationUrl();
        loginDialog.open();
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
}
