/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2018  Sander van Grieken

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
    title: qsTr("App Settings")

    SilicaListView {
        id: settingFlickable
        anchors.fill: parent

        Component.onCompleted: settingFlickable.positionViewAtBeginning();

        header: Column {
            id: settingColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            QuickdditPageHeader { title: appSettingsPage.title }

            SectionHeader { text: qsTr("Display") }

            ComboBox {
                label: qsTr("Font Size")
                currentIndex:  {
                    switch (appSettings.fontSize) {
                    case AppSettings.TinyFontSize: return 0;
                    case AppSettings.SmallFontSize: return 1;
                    case AppSettings.MediumFontSize: return 2;
                    case AppSettings.LargeFontSize: return 3;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: qsTr("Tiny") }
                    MenuItem { text: qsTr("Small") }
                    MenuItem { text: qsTr("Medium") }
                    MenuItem { text: qsTr("Large") }
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
                label: qsTr("Device Orientation")
                currentIndex:  {
                    switch (appSettings.orientationProfile) {
                    case AppSettings.DynamicProfile: return 0;
                    case AppSettings.PortraitOnlyProfile: return 1;
                    case AppSettings.LandscapeOnlyProfile: return 2;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: qsTr("Automatic") }
                    MenuItem { text: qsTr("Portrait only") }
                    MenuItem { text: qsTr("Landscape only") }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: appSettings.orientationProfile = AppSettings.DynamicProfile; break;
                    case 1: appSettings.orientationProfile = AppSettings.PortraitOnlyProfile; break;
                    case 2: appSettings.orientationProfile = AppSettings.LandscapeOnlyProfile; break;
                    }
                }
            }

            ComboBox {
                label: qsTr("Thumbnail Size")
                currentIndex:  {
                    switch (appSettings.thumbnailScale) {
                    case AppSettings.ScaleAuto: return 0;
                    case AppSettings.Scale100: return 1;
                    case AppSettings.Scale125: return 2;
                    case AppSettings.Scale150: return 3;
                    case AppSettings.Scale175: return 4;
                    case AppSettings.Scale200: return 5;
                    case AppSettings.Scale250: return 6;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: qsTr("Auto") }
                    MenuItem { text: "x1" }
                    MenuItem { text: "x1.25" }
                    MenuItem { text: "x1.5" }
                    MenuItem { text: "x1.75" }
                    MenuItem { text: "x2" }
                    MenuItem { text: "x2.5" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: appSettings.thumbnailScale = AppSettings.ScaleAuto; break;
                    case 1: appSettings.thumbnailScale = AppSettings.Scale100; break;
                    case 2: appSettings.thumbnailScale = AppSettings.Scale125; break;
                    case 3: appSettings.thumbnailScale = AppSettings.Scale150; break;
                    case 4: appSettings.thumbnailScale = AppSettings.Scale175; break;
                    case 5: appSettings.thumbnailScale = AppSettings.Scale200; break;
                    case 6: appSettings.thumbnailScale = AppSettings.Scale250; break;
                    }
                }
            }

            ComboBox {
                visible: false // not functional yet
                label: qsTr("Language")
                currentIndex:  {
                    // TODO: return indexOf appsetting in model
                    return 0;
                }
                menu: ContextMenu {
                    MenuItem { text: "Default" }
                    MenuItem { text: "English" }
                    MenuItem { text: "Dutch" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                        // TODO : set appsettings language to lang_id at index in model
                    }
                }
            }

            SectionHeader { text: qsTr("Notifications") }

            TextSwitch {
                text: qsTr("Check Messages")
                checked: appSettings.pollUnread;
                enabled: quickdditManager.isSignedIn
                onCheckedChanged: {
                    appSettings.pollUnread = checked;
                }
            }

            SectionHeader { text: qsTr("Media") }

            ComboBox {
                label: qsTr("Preferred Video Size")
                currentIndex:  {
                    switch (appSettings.preferredVideoSize) {
                    case AppSettings.VS360: return 0;
                    case AppSettings.VS720: return 1;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: "360p" }
                    MenuItem { text: "720p" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: appSettings.preferredVideoSize = AppSettings.VS360; break;
                    case 1: appSettings.preferredVideoSize = AppSettings.VS720; break;
                    }
                }
            }

            TextSwitch {
                text: qsTr("Loop Videos")
                checked: appSettings.loopVideos;
                onCheckedChanged: {
                    appSettings.loopVideos = checked;
                }
            }

            SectionHeader { text: qsTr("Connection") }

            TextSwitch {
                text: qsTr("Use Tor")
                description: qsTr("When enabled, please make sure Tor is installed and active.")
                checked: appSettings.useTor;
                onCheckedChanged: {
                    appSettings.useTor = checked;
                }
            }

            SectionHeader { text: qsTr("Account") }

            Text {
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                visible: quickdditManager.isSignedIn
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Signed in to Reddit as")
            }

            Text {
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeLarge
                color: Theme.secondaryHighlightColor
                visible: quickdditManager.isSignedIn
                horizontalAlignment: Text.AlignHCenter
                text: appSettings.redditUsername
            }

            Rectangle {
                color: "transparent"
                height: 10
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: quickdditManager.isSignedIn ? qsTr("Sign out") : qsTr("Sign in to Reddit")
                onClicked: {
                    if (quickdditManager.isSignedIn) {
                        quickdditManager.signOut();
                        infoBanner.alert(qsTr("You have signed out from Reddit"));
                     } else {
                        pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
                    }
                }
            }

            Rectangle {
                color: "transparent"
                height: 10
            }
        }

        model: appSettings.accountNames

        delegate: ListItem {
            id: listItem
            enabled: modelData !== appSettings.redditUsername

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: constant.paddingMedium

                IconButton {
                    icon.source: "image://theme/icon-m-person"
                    highlighted: listItem.highlighted || appSettings.redditUsername === modelData
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    color: listItem.highlighted || appSettings.redditUsername === modelData ? Theme.highlightColor : constant.colorLight
                    font.pixelSize: constant.fontSizeLarger
                    font.bold: true
                    text: modelData
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            showMenuOnPressAndHold: false
            onClicked: {
                var dialog = showMenu({item: modelData});
                dialog.removeAccount.connect(function() {
                    listItem.remorseAction(qsTr("Remove %1 account").arg(modelData), function() {
                        appSettings.removeAccount(modelData);
                    })
                });
                dialog.activateAccount.connect(function() {
                    quickdditManager.selectAccount(modelData);
                });
            }

            menu: Component {
                ContextMenu {
                    property string item
                    signal removeAccount
                    signal activateAccount

                    MenuItem {
                        text: qsTr("Activate")
                        onClicked: activateAccount()
                    }
                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: removeAccount()
                    }
                }
            }
        }
    }
}
