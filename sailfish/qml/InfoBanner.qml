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

MouseArea {
    id: infoBanner

    function alert(text) {
        messageText.text = text;
        infoBanner.opacity = 1.0;
        hideTimer.start();
    }

    width: Screen.width
    height: messageText.height + 2 * constant.paddingMedium
    visible: opacity > 0.0
    opacity: 0.0

    Behavior on opacity { FadeAnimation {} }

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightColor
    }

    Text {
        id: messageText
        anchors {
            left: parent.left; right: parent.right; margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: constant.fontSizeSmall
        color: constant.colorLight
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        maximumLineCount: 3
    }

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: infoBanner.opacity = 0.0;
    }

    onClicked: {
        opacity = 0.0;
        hideTimer.stop();
    }
}
