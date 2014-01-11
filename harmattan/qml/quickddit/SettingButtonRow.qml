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

Item {
    id: root

    property string text: ""
    property variant buttonsText: []
    property int checkedButtonIndex: 0

    signal buttonClicked(int index)

    width: parent.width
    height: settingText.paintedHeight + buttonRow.height + buttonRow.anchors.topMargin

    Text {
        id: settingText
        anchors { left: parent.left; top: parent.top; leftMargin: constant.paddingMedium }
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        text: root.text
    }

    ButtonRow {
        id: buttonRow
        anchors {
            top: settingText.bottom
            left: parent.left
            right: parent.right
            margins: constant.paddingSmall
        }

        Repeater {
            id: buttonRepeater
            model: root.buttonsText

            Button {
                text: modelData
                onClicked: root.buttonClicked(index)
            }
        }
    }

    Component.onCompleted: {
        if (buttonRepeater.count > 0)
            buttonRow.checkedButton = buttonRepeater.itemAt(root.checkedButtonIndex)
    }
}
