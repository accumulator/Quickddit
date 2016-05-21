/*
    Quickddit - Reddit client for mobile phones
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
import harbour.quickddit.Core 1.0

Image {
    id: thumbnail

    property variant link
    property bool enabled: true

    source: link.thumbnailUrl
    asynchronous: true

    MouseArea {
        anchors.fill: parent
        enabled: !link.isSelfPost && thumbnail.enabled
        onClicked: globalUtils.openLink(link.url)
    }

    onStatusChanged: {
        if (thumbnail.status === Image.Ready) {
            if (appSettings.thumbnailScale === AppSettings.ScaleAuto) {
                width = width * QMLUtils.pScale
                height = height * QMLUtils.pScale
            } else {
                var scale = 1 + ((appSettings.thumbnailScale - 1) * 0.25) // naughty
                width = width * scale
                height = height * scale
            }
        }
    }
}
