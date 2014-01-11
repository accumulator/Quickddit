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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate

    property bool showSubreddit: true

    contentHeight: Math.max(thumbnail.height, textColumn.height) + (2 * constant.paddingMedium)

    Column {
        id: textColumn
        anchors {
            left: parent.left; right: thumbnail.left; margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height
        spacing: constant.paddingSmall

        Text {
            id: titleText
            anchors { left: parent.left; right: parent.right }
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 3
            font.pixelSize: constant.fontSizeDefault
            color: constant.colorLight
            font.bold: true
            text: model.title + " (" + model.domain + ")"
        }

        Text {
            id: timeAndAuthorText
            anchors { left: parent.left; right: parent.right }
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 2
            font.pixelSize: constant.fontSizeDefault
            color: constant.colorMid
            text: "submitted " + model.created + " by " + model.author +
                  (showSubreddit ? " to " + model.subreddit : "")
        }

        Row {
            anchors { left: parent.left; right: parent.right }
            spacing: constant.paddingMedium

            CustomCountBubble {
                value: model.score
                colorMode: model.likes
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                text: "points"
            }

            CustomCountBubble {
                value: model.commentsCount
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                text: "comments"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: "green"
                visible: model.isSticky
                text: "Sticky"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: "red"
                visible: model.isNSFW
                text: "NSFW"
            }
        }
    }

    Image {
        id: thumbnail
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: constant.paddingMedium }
        source: model.thumbnailUrl
        asynchronous: true
    }
}
