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
import quickddit.Core 1.0
import QtGraphicalEffects 1.0

Image {
    property bool video
    property bool image
    property bool urlPost
    property variant link

    width: 140*persistantSettings.scale
    height: visible ? width : 0


    fillMode: Image.PreserveAspectFit
    source: String(link.thumbnailUrl).length>1 ? link.thumbnailUrl : "https://www.google.com/s2/favicons?sz=64&domain_url=" + link.domain

    MouseArea {
        anchors.fill: parent
        enabled: urlPost||video
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.2
            visible: parent.pressed
        }
        onClicked: {
            globalUtils.openLink(link.url);
        }
    }

    Rectangle{
        anchors{left: parent.left ; right: parent.right; bottom: parent.bottom}
        visible: urlPost
        color: "black"
        opacity: 0.6
        height: 40
        Label {
            text: link.domain
            color: "white"
            font.weight: Font.DemiBold
            width: parent.width
            anchors.centerIn: parent
            horizontalAlignment: "AlignHCenter"
            elide: "ElideRight"
            maximumLineCount: 1
        }
    }

    Image {
        anchors.centerIn: parent
        source: Qt.resolvedUrl("../Icons/media-playback-start.svg")
        visible: video
        opacity: 0.7
    }
}
