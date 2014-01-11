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

Item {
    id: sectionHeader
    anchors { left: parent.left; right: parent.right }
    height: titleText.height

    property string title

    Rectangle {
        id: line
        anchors {
            left: parent.left
            right: titleText.left; rightMargin: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        height: 1
        color: constant.colorMid
    }

    Text {
        id: titleText
        anchors { right: parent.right; rightMargin: constant.paddingMedium }
        font.pixelSize: constant.fontSizeSmall
        font.bold: true
        color: constant.colorMid
        text: sectionHeader.title
    }
}
