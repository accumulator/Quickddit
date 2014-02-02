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

Dialog {
    id: openLinkDialog

    property string url

    canAccept: false

    Column {
        anchors { left: parent.left; right: parent.right }

        DialogHeader { title: "URL" }

        Item {
            anchors { left: parent.left; right: parent.right }
            height: urlLabel.height + urlSeparator.height + 2 * constant.paddingLarge

            Label {
                id: urlLabel
                anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge }
                color: Theme.highlightColor
                font.pixelSize: constant.fontSizeMedium
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 3
                elide: Text.ElideRight
                text: url
            }

            Separator {
                id: urlSeparator
                anchors {
                    left: parent.left; right: parent.right
                    top: urlLabel.bottom; topMargin: constant.paddingLarge
                }
                color: constant.colorMid
            }
        }

        SimpleListItem {
            text: "Open URL in web browser"
            onClicked: {
                Qt.openUrlExternally(url);
                infoBanner.alert("Launching web browser...");
                openLinkDialog.close();
            }
        }

        SimpleListItem {
            text: "Copy URL"
            onClicked: {
                QMLUtils.copyToClipboard(url);
                infoBanner.alert("URL copied to clipboard");
                openLinkDialog.close();
            }
        }
    }
}
