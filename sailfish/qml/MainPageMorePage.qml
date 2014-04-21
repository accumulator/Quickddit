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

import QtQuick 2.0
import Sailfish.Silica 1.0

AbstractPage {
    id: mainPageMorePage
    title: "More"

    signal multiredditsClicked

    Flickable {
        anchors.fill: parent
        contentHeight: pageHeader.height + optionsColumn.height

        PageHeader {
            id: pageHeader
            title: mainPageMorePage.title
        }

        Column {
            id: optionsColumn
            anchors { top: pageHeader.bottom; left: parent.left; right: parent.right }
            height: childrenRect.height

            SimpleListItem {
                enabled: quickdditManager.isSignedIn
                text: "Multireddits"
                onClicked: multiredditsClicked();
            }

            SimpleListItem {
                enabled: quickdditManager.isSignedIn
                text: "Messages"
                onClicked: pageStack.replace(Qt.resolvedUrl("MessagePage.qml"));
            }

            SimpleListItem {
                text: "Search"
                onClicked: pageStack.replace(Qt.resolvedUrl("SearchDialog.qml"));
            }

            SimpleListItem {
                text: "Settings"
                onClicked: pageStack.replace(Qt.resolvedUrl("AppSettingsPage.qml"))
            }

            SimpleListItem {
                text: "About"
                onClicked: pageStack.replace(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }
}
