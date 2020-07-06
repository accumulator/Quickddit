/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2016  Sander van Grieken

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
import QtGraphicalEffects 1.0

ListItem {
    id: subredditDelegate
    contentHeight: mainColumn.height + 2 * constant.paddingMedium

    Column {
        id: mainColumn
        anchors {
            left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
            margins: constant.paddingMedium
        }
        height: childrenRect.height
        spacing: constant.paddingSmall

        Row {
            spacing: Theme.paddingMedium

            Image {
                id: subredditIcon
                height: (status == Image.Error || status == Image.Null) ? 0 : Theme.itemSizeSmall
                width: height
                anchors.verticalCenter: parent.verticalCenter
                source: model.iconUrl
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: subredditIcon.width
                        height: subredditIcon.height
                        radius: subredditIcon.width/4
                    }
                }
            }

            Column {
                Row {
                    height: subredditText.height + anchors.topMargin + anchors.bottomMargin

                    Text {
                        id: titleText
                        font.pixelSize: constant.fontSizeMedium
                        color: subredditDelegate.highlighted ? Theme.highlightColor : constant.colorMid
                        text: "/r/"
                    }
                    Text {
                        id: subredditText
                        anchors.baseline: titleText.baseline
                        font.pixelSize: constant.fontSizeMedium
                        font.bold: true
                        color: subredditDelegate.highlighted ? Theme.highlightColor : constant.colorLight
                        text: model.displayName
                    }
                }

                Text {
                    font.pixelSize: constant.fontSizeDefault
                    color: subredditDelegate.highlighted ? Theme.secondaryHighlightColor : constant.colorMid
                    wrapMode: Text.Wrap
                    text: qsTr("%n subscribers", "", model.subscribers)
                }
            }
        }

        Text {
            anchors { left: parent.left; right: parent.right; leftMargin: constant.paddingMedium }
            font.pixelSize: constant.fontSizeDefault
            color: subredditDelegate.highlighted ? Theme.highlightColor : constant.colorLight
            wrapMode: Text.Wrap
            textFormat: Text.StyledText
            visible: text != ""
            text: model.shortDescription !== "" ? model.shortDescription : model.title
        }

    }
}
