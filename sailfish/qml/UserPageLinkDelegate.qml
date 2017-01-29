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

ListItem {
    id: mainItem

    property variant model
    property bool markSaved: true

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
            anchors { left: parent.left; right: parent.right }
            spacing: constant.paddingMedium

            Bubble {
                visible: model.flairText !== ""
                text: model.flairText
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                color: "green"
                visible: !!model.isSticky
                text: "Sticky"
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                color: "red"
                visible: !!model.isNSFW
                text: "NSFW"
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                color: "green"
                visible: !!model.isPromoted
                text: "Promoted"
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                visible: !!model.gilded && model.gilded > 0
                text: model.gilded > 1 ? "Gilded " + model.gilded + "x" : "Gilded"
                color: "gold"
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }
        }

        Row {
            width: parent.width
            spacing: constant.paddingSmall
            clip: true

            Image {
                source: model.isSelfPost ? "image://theme/icon-m-bubble-universal" : "image://theme/icon-m-link"
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: titleText
                font.pixelSize: constant.fontSizeDefault
                color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                        : constant.colorDisabled
                font.bold: true
                text: model.isSelfPost ? "Self Post in /r/" + model.subreddit
                                       : "Link in /r/" + model.subreddit
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
            text: model.title
        }

        Text {
            visible: model.isSelfPost
            width: parent.width - 25
            x: 25
            text: /(<p>(.*?)<\/p>).*/.exec(model.text)[2]
            textFormat: Text.StyledText
            font.pixelSize: constant.fontSizeSmaller
            color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                    : constant.colorDisabled
            linkColor: mainItem.enabled ? Theme.highlightColor : constant.colorDisabled
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 5

            Rectangle {
                x: -25
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 10
                color: constant.colorDisabled
                opacity: 0.33
            }
        }

    }

    Image {
        visible: model.saved && markSaved
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

}
