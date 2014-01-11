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

Page {
    id: abstractPage

    default property alias data: contentItem.data

    property string title
    property bool busy: false

    signal headerClicked

    Item {
        id: contentItem
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
    }

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: constant.headerHeight

        BorderImage {
            anchors.fill: parent
            border { top: 15; left: 15; right: 15 }
            source: "image://theme/meegotouch-view-header-fixed" + (appSettings.whiteTheme ? "" : "-inverted")
                    + (mouseArea.pressed ? "-pressed" : "")
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left; right: busyLoader.left
                margins: constant.paddingLarge
            }
            font.pixelSize: constant.fontSizeXLarge
            color: constant.colorLight
            elide: Text.ElideRight
            text: abstractPage.title
        }

        Loader {
            id: busyLoader
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right; rightMargin: constant.paddingLarge
            }
            sourceComponent: abstractPage.busy ? updatingIndicator : undefined

            Component { id: updatingIndicator; BusyIndicator { running: true } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: abstractPage.headerClicked();
        }
    }
}
