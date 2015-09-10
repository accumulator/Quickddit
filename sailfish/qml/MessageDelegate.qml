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
    id: messageDelegate
    contentHeight: messageColumn.height + 2 * constant.paddingMedium

    property bool isSentMessage: false

    Column {
        id: messageColumn
        anchors {
            left: unreadIndicator.visible ? unreadIndicator.right : parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height

        Text {
            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeDefault
            color: messageDelegate.highlighted ? Theme.highlightColor : constant.colorLight
            font.bold: true
            font.capitalization: model.isComment ? Font.Capitalize : Font.MixedCase
            elide: Text.ElideRight
            text: model.subject
        }

        Text {
            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeDefault
            color: messageDelegate.highlighted ? Theme.highlightColor : constant.colorLight
            font.italic: true
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            visible: text.length > 0
            text: model.linkTitle
        }

        Text {
            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeDefault
            color: messageDelegate.highlighted ? Theme.secondaryHighlightColor: constant.colorMid
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            text: (isSentMessage ? "to " + model.destination : "from " + model.author)
                  + (model.subreddit ? " via /r/" + model.subreddit : "")
                  + " sent " + model.created
        }

        Text {
            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
            font.pixelSize: constant.fontSizeDefault
            color: messageDelegate.highlighted ? Theme.highlightColor : constant.colorLight
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: "<style>a { color: " + Theme.highlightColor + "; }</style>" + model.body
            clip: true
        }
    }

    Rectangle {
        id: unreadIndicator
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; margins: constant.paddingMedium }
        width: visible ? constant.paddingMedium : 0
        color: "royalblue"
        visible: model.isUnread
    }
}
