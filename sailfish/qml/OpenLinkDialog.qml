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

    readonly property string title: "Open URL"
    property string url

    property bool __buttonClickAccept: false

    onAccepted: {
        // user accept the dialog by swiping to left instead of clicking on the button
        if (!__buttonClickAccept) {
            Qt.openUrlExternally(url);
            infoBanner.alert("Launching web browser...");
        }
    }

    Column {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        spacing: constant.paddingLarge

        DialogHeader { title: openLinkDialog.title }

        Label {
            anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge }
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 4
            elide: Text.ElideRight
            text: url
        }
    }

    Column {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: constant.paddingLarge }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Open URL in web browser"
            onClicked: {
                Qt.openUrlExternally(url);
                infoBanner.alert("Launching web browser...");
                __buttonClickAccept = true;
                openLinkDialog.accept();
            }
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Copy URL"
            onClicked: {
                QMLUtils.copyToClipboard(url);
                infoBanner.alert("URL copied to clipboard");
                __buttonClickAccept = true;
                openLinkDialog.accept();
            }
        }
    }
}
