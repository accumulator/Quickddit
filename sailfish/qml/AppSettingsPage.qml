/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: appSettingsPage
    title: "App Settings"

    Flickable {
        id: settingFlickable
        anchors.fill: parent
        contentHeight: settingColumn.height

        Column {
            id: settingColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            PageHeader { title: appSettingsPage.title }

            SectionHeader { text: "Display" }

            ComboBox {
                label: "Font Size"
                currentIndex:  {
                    switch (appSettings.fontSize) {
                    case AppSettings.TinyFontSize: return 0;
                    case AppSettings.SmallFontSize: return 1;
                    case AppSettings.MediumFontSize: return 2;
                    case AppSettings.LargeFontSize: return 3;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: "Tiny" }
                    MenuItem { text: "Small" }
                    MenuItem { text: "Medium" }
                    MenuItem { text: "Large" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: appSettings.fontSize = AppSettings.TinyFontSize; break;
                    case 1: appSettings.fontSize = AppSettings.SmallFontSize; break;
                    case 2: appSettings.fontSize = AppSettings.MediumFontSize; break;
                    case 3: appSettings.fontSize = AppSettings.LargeFontSize; break;
                    }
                }
            }

            ComboBox {
                label: "Device Orientation"
                currentIndex:  {
                    switch (appSettings.orientationProfile) {
                    case AppSettings.DynamicProfile: return 0;
                    case AppSettings.PortraitOnlyProfile: return 1;
                    case AppSettings.LandscapeOnlyProfile: return 2;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: "Automatic" }
                    MenuItem { text: "Portrait only" }
                    MenuItem { text: "Landscape only" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: appSettings.orientationProfile = AppSettings.DynamicProfile; break;
                    case 1: appSettings.orientationProfile = AppSettings.PortraitOnlyProfile; break;
                    case 2: appSettings.orientationProfile = AppSettings.LandscapeOnlyProfile; break;
                    }
                }
            }

            SectionHeader { text: "Notifications" }

            ComboBox {
                label: "Check Messages"
                currentIndex:  {
                    return appSettings.pollUnread ? 0 : 1;
                }
                menu: ContextMenu {
                    MenuItem { text: "On" }
                    MenuItem { text: "Off" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: appSettings.pollUnread = true; break;
                    case 1: appSettings.pollUnread = false; break;
                    }
                }
            }

            SectionHeader { text: "Account" }

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
