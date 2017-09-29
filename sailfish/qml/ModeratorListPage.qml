/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2017  Sander van Grieken

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

AbstractPage {
    id: moderatorsPage
    title: qsTr("Moderators")
    busy: manager.busy

    property AboutSubredditManager manager

    SilicaListView {
        id: moderatorListView

        anchors.fill: parent

        model: manager.moderators

        header: QuickdditPageHeader { title: moderatorsPage.title }

        delegate: ListItem {
            id: item
            width: ListView.view.width

            Column {
                id: mainColumn
                anchors {
                    left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                    margins: constant.paddingLarge
                }
                spacing: constant.paddingSmall

                Row {
                    id: itemRow
                    anchors { left: parent.left; right: parent.right }
                    Text {
                        id: titleText
                        font.pixelSize: constant.fontSizeSmall
                        color: item.highlighted ? Theme.highlightColor : constant.colorMid
                        text: "/u/"
                    }

                    Text {
                        anchors.baseline: titleText.baseline
                        font.pixelSize: constant.fontSizeMedium
                        color: item.highlighted ? Theme.highlightColor : constant.colorLight
                        text: display
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        manager.getModerators()
    }

}
