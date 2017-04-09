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

AbstractPage {
    id: aboutPage
    title: qsTr("About")

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: aboutPage.width * 0.8
        height: aboutPage.height * 0.8

        fillMode: Image.PreserveAspectFit
        source: "./cover/background.png"
        opacity: 0.1
        smooth: true
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: header.height + columnWrapper.height
        flickableDirection: Flickable.VerticalFlick

        QuickdditPageHeader { id: header; title: aboutPage.title }

        Item {
            id: columnWrapper
            anchors { left: parent.left; right: parent.right; top: header.bottom }
            height: Math.max(column.height + 2 * constant.paddingMedium, flickable.height - header.height)

            Column {
                id: column
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: childrenRect.height
                spacing: Theme.paddingLarge

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "image://theme/harbour-quickddit"
                }

                Text {
                    anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: constant.fontSizeMedium
                    color: Theme.highlightColor
                    wrapMode: Text.Wrap
                    text: "Quickddit - A free and open source Reddit client for mobile phones\n" +
                          "v" + APP_VERSION
                }

                Text {
                    anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: constant.fontSizeSmall
                    color: constant.colorLight
                    wrapMode: Text.Wrap
                    text: "Copyright (c) 2015-2016 Sander van Grieken\n" +
                          "Copyright (c) 2013-2014 Dickson Leong\n\n" +
                          "App icon by Andrew Zhilin\n\n" +
                          "Licensed under GNU GPLv3+\n"
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingLarge

                    Button {
                        text: qsTr("Source")
                        onClicked: globalUtils.createOpenLinkDialog(QMLUtils.SOURCE_REPO_URL);
                    }

                    Button {
                        text: qsTr("License")
                        onClicked: globalUtils.createOpenLinkDialog(QMLUtils.GPL3_LICENSE_URL);
                    }
                }
            }
        }
    }
}
