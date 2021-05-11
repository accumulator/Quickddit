/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

ItemDelegate {
    id:multiredditDelegate

    width: parent.width
    height: Math.max(ico.height+10,titleText.height + fullText.height+20)
    Image {
        id:ico
        width: 64
        height: 64
        source:model.iconUrl
        anchors{left: parent.left; top: parent.top;margins: 5}
        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource: Rectangle{
                width: 64
                height: width
                radius: width
            }
        }
    }

    Label {
        id:titleText
        anchors{left: ico.right;right: parent.right;top: parent.top;margins: 5}
        elide: "ElideRight"
        text: "/m/"+model.name//+" ("+model.title+")"
        font.bold: true
    }

    Label {
        id:fullText
        anchors {top: titleText.bottom;left: ico.right;right: parent.right;margins: 5}
        text: model.description

        wrapMode: "Wrap"
        elide: "ElideRight"
        maximumLineCount: 3
    }
}
