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

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

AbstractPage {
    id: appSettingsPage
    title: "App Settings"

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: settingFlickable
        anchors.fill: parent
        contentHeight: settingColumn.height + 2 * constant.paddingMedium

        Column {
            id: settingColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            SectionHeader { title: "Display" }

            SettingButtonRow {
                text: "Theme"
                checkedButtonIndex: appSettings.whiteTheme ? 1 : 0
                buttonsText: ["Dark", "White"]
                onButtonClicked: appSettings.whiteTheme = index == 1
            }

            SettingButtonRow {
                text: "Font Size"
                checkedButtonIndex: {
                    switch (appSettings.fontSize) {
                    case AppSettings.SmallFontSize: return 0;
                    case AppSettings.MediumFontSize: return 1;
                    case AppSettings.LargeFontSize: return 2;
                    }
                }
                buttonsText: ["Small", "Medium", "Large"]
                onButtonClicked: {
                    switch (index) {
                    case 0: appSettings.fontSize = AppSettings.SmallFontSize; break;
                    case 1: appSettings.fontSize = AppSettings.MediumFontSize; break;
                    case 2: appSettings.fontSize = AppSettings.LargeFontSize; break;
                    }
                }
            }

            SectionHeader { title: "Account" }

            Text {
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                visible: quickdditManager.isSignedIn
                horizontalAlignment: Text.AlignHCenter
                text: "Signed in to Reddit" + (appSettings.redditUsername ? " as " + appSettings.redditUsername : "")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: quickdditManager.isSignedIn ? "Sign out" : "Sign in to Reddit"
                onClicked: {
                    if (quickdditManager.isSignedIn) {
                        quickdditManager.signOut();
                        infoBanner.alert("You have signed out from Reddit");
                     } else {
                        pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
                    }
                }
            }
        }
    }
}
