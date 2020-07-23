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

import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property string source
    id: logoRect
    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight
    radius: width;
    color:"white"
    clip: true

    Image{
        anchors.centerIn: parent
        id:image
        source: parent.source
        width: parent.width-10
        height: parent.height-10
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: image.width
                height: image.height
                radius: image.width
            }
        }
    }
}
