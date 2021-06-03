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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Suru 2.2

ToolButton {
    id: actionButton
    height: parent.height
    width: Suru.units.gu(4.5)
    hoverEnabled: false
    //after QT update we can use icon property
    property url ico
    property color color
    property int size: Suru.units.gu(3)
    Image {
        anchors.centerIn: parent
        source: ico
        width: size
        height: size
        layer.enabled: true
        layer.effect: ColorOverlay {
            color: actionButton.color
        }
    }
}
