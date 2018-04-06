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

    contentHeight: Math.max(mainColumn.height + 2 * constant.paddingMedium, thumb.height)
    showMenuOnPressAndHold: false

    PostThumbnail {
        id: thumb
        anchors {
            right: parent.right; margins: constant.paddingMedium
            verticalCenter:  parent.verticalCenter
        }
        visible: !model.isSelfPost
        enabled: visible
        link: model
    }

    Column {
        id: mainColumn
        anchors {
            left: parent.left; right: thumb.left; margins: constant.paddingMedium
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
                text: qsTr("Sticky")
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                color: "red"
                visible: !!model.isNSFW
                text: qsTr("NSFW")
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                color: "green"
                visible: !!model.isPromoted
                text: qsTr("Promoted")
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                visible: !!model.gilded && model.gilded > 0
                text: model.gilded > 1 ? qsTr("Gilded") + " " + model.gilded + "x" : qsTr("Gilded")
                color: "gold"
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

            Bubble {
                color: Qt.lighter("purple", 1.5)
                visible: !!model.isLocked
                text: qsTr("Locked")
                font.bold: true
                font.pixelSize: constant.fontSizeSmaller
            }

        }

        Row {
            width: parent.width
            spacing: constant.paddingSmall

            Image {
                id: itemIcon
                source: model.isSelfPost ? "image://theme/icon-m-bubble-universal" : "image://theme/icon-m-link"
                width: 32 * QMLUtils.pScale
                height: 32 * QMLUtils.pScale
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: mainColumn.width - itemIcon.width
                font.pixelSize: constant.fontSizeDefault
                font.bold: true
                color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                        : constant.colorDisabled
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                text: model.title
            }
        }

        Text {
            font.pixelSize: constant.fontSizeSmaller
            color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                    : constant.colorDisabled
            text: (model.isSelfPost ? "/r/" + model.subreddit
                                    : "/r/" + model.subreddit) + " · " + model.created
        }

        Text {
            visible: !model.isSelfPost
            font.pixelSize: constant.fontSizeSmaller
            font.bold: true
            color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                    : constant.colorDisabled
            text: model.domain
        }

        Text {
            visible: model.isSelfPost
            width: parent.width - 25
            x: 25
            text: {
                return globalUtils.formatForStyledText(model.text)
            }
            textFormat: Text.StyledText
            font.pixelSize: constant.fontSizeDefault
            color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                    : constant.colorDisabled
            linkColor: mainItem.enabled ? Theme.highlightColor : constant.colorDisabled
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 6

            Rectangle {
                x: -25
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 10
                color: Theme.secondaryHighlightColor
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
