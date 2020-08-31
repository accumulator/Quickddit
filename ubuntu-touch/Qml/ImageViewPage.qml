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

Page {
    property alias imageUrl: viewer.source
    property alias imgurUrl: imgurManager.imgurUrl

    Flickable{
        id:f
        anchors.fill: parent
        contentHeight: viewer.height
        contentWidth: viewer.width
        onHeightChanged: {
            viewer._fitToScreen();
        }
        ImageViewer{
            id:viewer
            flickable: f
        }
    }

    ImgurManager {
        id: imgurManager
        manager: quickdditManager
        onError: {
            infoBanner.warning(errorString);
        }
    }

    Binding {
        target: viewer
        property: "source"
        value: imgurManager.imageUrl
        when: imgurUrl
    }

}
