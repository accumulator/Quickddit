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

import QtQuick 1.1
import com.nokia.meego 1.0

ContextMenu {
    id: root

    property string url
    property string source

    platformTitle: Text {
        anchors { left: parent.left; right: parent.right }
        horizontalAlignment: Text.AlignHCenter
        text: url
        font.italic: true
        font.pixelSize: constant.fontSizeMedium
        color: constant.colorLight
        elide: Text.ElideRight
        maximumLineCount: 3
        wrapMode: Text.WrapAnywhere
    }

    MenuLayout {
        MenuItem {
            text: "Open URL in web browser"
            onClicked: {
                Qt.openUrlExternally(url);
                infoBanner.alert("Launching web browser...");
            }
        }
        MenuItem {
            text: "Copy URL"
            onClicked: {
                QMLUtils.copyToClipboard(url);
                infoBanner.alert("URL copied to clipboard");
            }
        }
        MenuItem {
            text: "Copy source URL"
            visible: source != ""
            onClicked: {
                QMLUtils.copyToClipboard(source);
                infoBanner.alert("URL copied to clipboard");
            }
        }
    }
}
