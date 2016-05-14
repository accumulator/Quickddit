/*
    Quickddit - Reddit client for mobile phones
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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: linkDelegate

    property bool showSubreddit: true

    contentHeight: Math.max(thumbnail.height, postInfoText.height) + (2 * constant.paddingMedium)

    PostInfoText {
        id: postInfoText

        link: model
        compact: true
        highlighted: linkDelegate.highlighted
        showSubreddit: linkDelegate.showSubreddit

        anchors {
            left: parent.left; right: thumbnail.left; margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }

        height: childrenRect.height
        spacing: constant.paddingSmall
    }

    PostThumbnail {
        id: thumbnail

        link: model
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: constant.paddingMedium }
    }

    Rectangle {
        id: savedRect
        anchors.fill: parent
        color: Theme.highlightColor
        opacity: model.saved ? 0.1 : 0.0
    }

    Image {
        visible: model.saved
        anchors {
            right: parent.right
            top: parent.top
        }
        source: "image://theme/icon-s-favorite?" + Theme.highlightColor
    }
}
