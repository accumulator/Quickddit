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

    property bool isPortrait: appWindow.deviceOrientation === Orientation.Portrait || appWindow.deviceOrientation === Orientation.PortraitInverted

    width: isPortrait ? parent.width : parent.height
    height: messageText.height + 2 * constant.paddingMedium
    visible: opacity > 0.0
    opacity: 0.0

    Behavior on opacity { FadeAnimation {} }

    Binding {
        target: infoBanner
        property: "y"
        value: {
            switch (appWindow.deviceOrientation) {
            case Orientation.Portrait:
                return 0
            case Orientation.Landscape:
            case Orientation.LandscapeInverted:
                return width / 2 - height //-halve hoogte + breedte
            case Orientation.PortraitInverted:
                return appWindow.height - 2*height
            }
        }
    }

    Binding {
        target: infoBanner
        property: "x"
        value: {
            switch (appWindow.deviceOrientation) {
            case Orientation.Portrait:
            case Orientation.PortraitInverted:
            case Orientation.Landscape:
                return 0
            case Orientation.LandscapeInverted:
                return 2*height - appWindow.width - 5 // where's this ~-5 offset issue coming from?? it doesn't align without it
            }
        }
    }

    transformOrigin: Item.Bottom

    rotation: {
        switch (appWindow.deviceOrientation) {
        case Orientation.Portrait:
            return 0
        case Orientation.Landscape:
            return 90
        case Orientation.PortraitInverted:
            return 180
        case Orientation.LandscapeInverted:
            return 270
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
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
