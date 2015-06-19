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

Sheet {
    id: textAreaDialog

    property alias title: headerItemText.text
    property alias text: textArea.text

    acceptButtonText: "Accept"
    rejectButtonText: "Cancel"
    acceptButton.enabled: text.length > 0 || textArea.platformPreedit.length > 0

    onAccepted: textArea.parent.focus = true; // force commit of predictive text

    content: Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: flickableColumn.height + 2 * constant.paddingMedium

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            Text {
                id: headerItemText
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeXLarge
                color: constant.colorLight
                elide: Text.ElideRight
            }

            TextArea {
                id: textArea
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                height: Math.max(implicitHeight, 300)
                font.pixelSize: constant.fontSizeLarge
                textFormat: Text.PlainText
                placeholderText: "Enter your comment here..."
                focus: true
            }
        }
    }
}
