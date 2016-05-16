/*
    Quickddit - Reddit client for mobile phones
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

Item {
    id: commentDelegate

    property variant model
    property bool markSaved: true

    signal clicked

    height: mainItem.height

    ListItem {
        id: mainItem

        contentHeight: mainColumn.height + 2 * constant.paddingMedium
        showMenuOnPressAndHold: false

        Column {
            id: mainColumn
            anchors {
                left: parent.left; right: parent.right; margins: constant.paddingMedium
                verticalCenter:  parent.verticalCenter
            }

            spacing: constant.paddingSmall

            Row {
                width: parent.width
                spacing: constant.paddingSmall
                clip: true

                Image {
                    source: "image://theme/icon-m-chat"
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    font.pixelSize: constant.fontSizeDefault
                    color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                            : constant.colorDisabled
                    font.bold: true
                    text: "Comment in /r/" + model.subreddit
                }
                Text {
                    font.pixelSize: constant.fontSizeDefault
                    color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                            : constant.colorDisabled
                    elide: Text.ElideRight
                    text: " · " + model.created
                }
            }

            Text {
                width: parent.width
                font.pixelSize: constant.fontSizeSmaller
                color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                        : constant.colorDisabled
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                text: model.linkTitle
            }

            WideText {
                width: parent.width
                body: model.body
                listItem: mainItem
                onClicked: commentDelegate.clicked();
            }

        }

        Image {
            visible: model.saved
            anchors {
                right: parent.right
                top: parent.top
                topMargin: 5
                rightMargin: 5
            }
            source: "image://theme/icon-s-favorite?" + Theme.highlightColor
        }

        Rectangle {
            anchors.fill: parent
            visible: model.saved && markSaved
            color: Theme.highlightColor
            opacity: 0.1
        }

        onClicked: commentDelegate.clicked();

    }

}

