/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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

    property bool isWarning: false

    function alert(text) {
        isWarning = false
        messageText.text = text;
        infoBanner.opacity = 1.0;
        hideTimer.start();
        console.log(text);
    }

    function warning(text) {
        isWarning = true
        messageText.text = text;
        infoBanner.opacity = 1.0;
        hideTimer.start();
        console.log(text);
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
            case Orientation.Landscape:
                return 0
            case Orientation.PortraitInverted:
                return appWindow.height
            case Orientation.LandscapeInverted:
                return width
            }
        }
    }

    Binding {
        target: infoBanner
        property: "x"
        value: {
            switch (appWindow.deviceOrientation) {
            case Orientation.Portrait:
            case Orientation.LandscapeInverted:
                return 0
            case Orientation.Landscape:
            case Orientation.PortraitInverted:
                return appWindow.width
            }
        }
    }

    transformOrigin: Item.TopLeft

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
        opacity: 0.95
    }

    Row {
        spacing: 20

        anchors {
            margins: constant.paddingMedium
            left: parent.left;
            right: parent.right;
            verticalCenter: parent.verticalCenter
        }

        Image {
            source: isWarning ? "image://theme/icon-lock-warning" : "image://theme/icon-lock-information"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: messageText
            font.pixelSize: constant.fontSizeSmall
            color: constant.colorLight
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 3
        }
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
