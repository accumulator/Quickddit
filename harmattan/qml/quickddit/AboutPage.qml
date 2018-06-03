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

import QtQuick 1.1
import com.nokia.meego 1.0

AbstractPage {
    id: aboutPage
    title: "About"

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: Math.max(column.height + 2 * constant.paddingMedium, flickable.height)

        Column {
            id: column
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
            height: childrenRect.height
            spacing: constant.paddingMedium

            Text {
                anchors { left: parent.left; right: parent.right }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                wrapMode: Text.Wrap
                text: "Quickddit - A free and open source Reddit client for mobile phones\n" +
                      "v" + APP_VERSION
            }

            Text {
                anchors { left: parent.left; right: parent.right }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                wrapMode: Text.Wrap
                text: "Copyright (c) 2015-2018 Sander van Grieken\n" +
                      "Copyright (c) 2013-2014 Dickson Leong\n" +
                      "App icon by Andrew Zhilin\n\n" +
                      "Licensed under GNU GPLv3+\n"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Source Repository"
                onClicked: globalUtils.createOpenLinkDialog(QMLUtils.SOURCE_REPO_URL);
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "License"
                onClicked: globalUtils.createOpenLinkDialog(QMLUtils.GPL3_LICENSE_URL);
            }
        }
    }
}
