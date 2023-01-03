/*
  Quickddit - Reddit client for mobile phones

  SPDX-FileCopyrightText:  Copyright (C) 2014  Dickson Leong
  SPDX-FileCopyrightText:  Copyright (C) 2015-2018  Sander van Grieken

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: settingsPage
    title: qsTr("Settings")

    SilicaListView {
        id: settingFlickable
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Accounts")
                onClicked: pageStack.push(Qt.resolvedUrl("AccountsPage.qml"));
            }
        }

        header: Column {
            id: settingColumn
            width: parent.width

            QuickdditPageHeader { title: settingsPage.title }

            SectionHeader { text: qsTr("UX") }

            ComboBox {
                label: qsTr("Font Size")
                currentIndex:  {
                    switch (settings.fontSize) {
                    case Settings.TinyFontSize: return 0;
                    case Settings.SmallFontSize: return 1;
                    case Settings.MediumFontSize: return 2;
                    case Settings.LargeFontSize: return 3;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: qsTr("Tiny"); font.pixelSize: constant.fontSizeXSmall }
                    MenuItem { text: qsTr("Small"); font.pixelSize: constant.fontSizeSmall }
                    MenuItem { text: qsTr("Medium"); font.pixelSize: constant.fontSizeMedium }
                    MenuItem { text: qsTr("Large"); font.pixelSize: constant.fontSizeLarge }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: settings.fontSize = Settings.TinyFontSize; break;
                    case 1: settings.fontSize = Settings.SmallFontSize; break;
                    case 2: settings.fontSize = Settings.MediumFontSize; break;
                    case 3: settings.fontSize = Settings.LargeFontSize; break;
                    }
                }
            }

            ComboBox {
                label: qsTr("Device Orientation")
                currentIndex:  {
                    switch (settings.orientationProfile) {
                    case Settings.DynamicProfile: return 0;
                    case Settings.PortraitOnlyProfile: return 1;
                    case Settings.LandscapeOnlyProfile: return 2;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: qsTr("Automatic") }
                    MenuItem { text: qsTr("Portrait only") }
                    MenuItem { text: qsTr("Landscape only") }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: settings.orientationProfile = Settings.DynamicProfile; break;
                    case 1: settings.orientationProfile = Settings.PortraitOnlyProfile; break;
                    case 2: settings.orientationProfile = Settings.LandscapeOnlyProfile; break;
                    }
                }
            }

            ComboBox {
                label: qsTr("Thumbnail Size")
                currentIndex:  {
                    switch (settings.thumbnailScale) {
                    case Settings.ScaleAuto: return 0;
                    case Settings.Scale100: return 1;
                    case Settings.Scale125: return 2;
                    case Settings.Scale150: return 3;
                    case Settings.Scale175: return 4;
                    case Settings.Scale200: return 5;
                    case Settings.Scale250: return 6;
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
                    case 0: settings.thumbnailScale = Settings.ScaleAuto; break;
                    case 1: settings.thumbnailScale = Settings.Scale100; break;
                    case 2: settings.thumbnailScale = Settings.Scale125; break;
                    case 3: settings.thumbnailScale = Settings.Scale150; break;
                    case 4: settings.thumbnailScale = Settings.Scale175; break;
                    case 5: settings.thumbnailScale = Settings.Scale200; break;
                    case 6: settings.thumbnailScale = Settings.Scale250; break;
                    }
                }
            }

            TextSwitch {
                text: qsTr("Thumbnail Link Type Indicator")
                checked: settings.showLinkType;
                onCheckedChanged: {
                    settings.showLinkType = checked;
                }
            }

            TextSwitch {
                text: qsTr("Comments Tap To Hide")
                checked: settings.commentsTapToHide;
                onCheckedChanged: {
                    settings.commentsTapToHide = checked;
                }
            }

            SectionHeader { text: qsTr("Notifications") }

            TextSwitch {
                text: qsTr("Check Messages")
                checked: settings.pollUnread;
                enabled: quickdditManager.isSignedIn
                onCheckedChanged: {
                    settings.pollUnread = checked;
                }
            }

            SectionHeader { text: qsTr("Media") }

            ComboBox {
                label: qsTr("Preferred Video Size")
                currentIndex:  {
                    switch (settings.preferredVideoSize) {
                    case Settings.VS360: return 0;
                    case Settings.VS720: return 1;
                    }
                }
                menu: ContextMenu {
                    MenuItem { text: "360p" }
                    MenuItem { text: "720p" }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: settings.preferredVideoSize = Settings.VS360; break;
                    case 1: settings.preferredVideoSize = Settings.VS720; break;
                    }
                }
            }

            TextSwitch {
                text: qsTr("Loop Videos")
                checked: settings.loopVideos;
                onCheckedChanged: {
                    settings.loopVideos = checked;
                }
            }

            SectionHeader { text: qsTr("Connection") }

            TextSwitch {
                text: qsTr("Use Tor")
                description: qsTr("When enabled, please make sure Tor is installed and active.")
                checked: settings.useTor;
                onCheckedChanged: {
                    settings.useTor = checked;
                }
            }
        }
    }
}
