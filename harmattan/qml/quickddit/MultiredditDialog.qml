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
import Quickddit.Core 1.0

Sheet {
    id: multiredditsDialog
    rejectButtonText: "Cancel"

    property alias multiredditModel: multiredditListView.model

    property string multiredditName

    content: Item {
        anchors.fill: parent

        Item {
            id: header
            anchors { left: parent.left; right: parent.right }
            height: constant.headerHeight

            Text {
                id: headerTitleText
                anchors {
                    left: parent.left; right: refreshItem.left; margins: constant.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                font.bold: true
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                elide: Text.ElideRight
                text: "Multireddits"
            }

            Image {
                id: refreshItem
                anchors {
                    right: parent.right; margins: constant.paddingMedium; verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-toolbar-refresh" + (multiredditModel.busy ? "-dimmed" : "")
                        + (appSettings.whiteTheme ? "" : "-white")

                MouseArea {
                    anchors.fill: parent
                    enabled: !multiredditModel.busy
                    onClicked: multiredditModel.refresh(false);
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: constant.colorMid
            }
        }

        ListView {
            id: multiredditListView
            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            clip: true
            delegate: SimpleListItem {
                text: "/m/" + model.name
                onClicked: {
                    multiredditsDialog.multiredditName = model.name;
                    multiredditsDialog.accept();
                }
            }

            footer: LoadingFooter { visible: multiredditModel.busy; listViewItem: multiredditListView }

            ViewPlaceholder { enabled: multiredditListView.count == 0 && !multiredditModel.busy }
        }
    }
}
