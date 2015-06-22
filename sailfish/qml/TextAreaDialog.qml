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

AbstractDialog {
    id: textAreaDialog

    property alias title: dialogHeader.title
    property alias text: textArea.text

    canAccept: text.length > 0

    onAccepted: Qt.inputMethod.commit(); // not sure if this is needed

    DialogHeader { id: dialogHeader }

    Flickable {
        id: flickable
        anchors { top: dialogHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        contentHeight: textArea.height
        clip: true

        TextArea {
            id: textArea
            anchors { left: parent.left; right: parent.right }
            height: Math.max(implicitHeight, Theme.itemSizeLarge * 3)
            placeholderText: "Enter your comment here..."
            focus: true
        }
    }
}
