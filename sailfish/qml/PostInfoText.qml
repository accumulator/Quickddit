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

Column {
    property variant link

    property bool compact: false
    property bool highlighted: false
    property bool showSubreddit: true

    spacing: constant.paddingMedium

    Row {
        anchors { left: parent.left; right: parent.right }
        spacing: constant.paddingMedium

        Bubble {
            visible: link.flairText !== ""
            text: link.flairText
        }

        Bubble {
            color: "green"
            visible: !!link.isSticky
            text: "Sticky"
            font.bold: true
        }

        Bubble {
            color: "red"
            visible: !!link.isNSFW
            text: "NSFW"
            font.bold: true
        }

        Bubble {
            color: "green"
            visible: !!link.isPromoted
            text: "Promoted"
            font.bold: true
        }

        Bubble {
            visible: !!link.gilded && link.gilded > 0
            text: link.gilded > 1 ? "Gilded " + link.gilded + "x" : "Gilded"
            color: "gold"
            font.bold: true
        }

        Bubble {
            visible: !!link.isArchived
            text: "Archived"
        }
    }

    Text {
        anchors { left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        elide: compact ? Text.ElideRight : Text.ElideNone
        maximumLineCount: compact ? 3 : 9999 /* TODO : maxint */
        font.pixelSize: constant.fontSizeDefault
        color: highlighted ? Theme.highlightColor : constant.colorLight
        font.bold: true
        text: link.title + " (" + link.domain + ")"
    }

    Text {
        id: submittedText
        anchors { left: parent.left; right: parent.right }
        wrapMode: Text.Wrap
        textFormat: Text.RichText
        elide: compact ? Text.ElideRight : Text.ElideNone
        maximumLineCount: compact ? 2 : 9999 /* TODO : maxint */
        font.pixelSize: constant.fontSizeDefault
        color: highlighted ? Theme.secondaryHighlightColor : constant.colorMid
        onLinkActivated: globalUtils.openLink(link)
        text: constant.richtextStyle + "submitted " + link.created + " by " +
                (compact ? link.author : "<a href=\"https://reddit.com/u/" + link.author.split(" ")[0] + "\">" + link.author + "</a>") +
                (showSubreddit ?
                     " to " + (compact ? link.subreddit : "<a href=\"https://reddit.com/r/" + link.subreddit + "\">" + link.subreddit + "</a>")
                     : "")
    }

    // viewhack to render richtext wide again after orientation goes horizontal (?)
    property bool oriChanged: false
    onWidthChanged: {
        if (oriChanged) submittedText.text = submittedText.text + " ";
    }
    Connections {
        target: appWindow
        onOrientationChanged: oriChanged = true
    }

    Row {
        anchors { left: parent.left; right: parent.right }
        spacing: constant.paddingMedium

        Text {
            font.pixelSize: constant.fontSizeDefault
            color: {
                if (link.likes > 0)
                    return constant.colorLikes;
                else if (link.likes < 0)
                    return constant.colorDislikes;
                else
                    return highlighted ? Theme.highlightColor : constant.colorLight;
            }
            text: link.score + " points"
        }

        Text {
            font.pixelSize: constant.fontSizeDefault
            color: highlighted ? Theme.highlightColor : constant.colorLight
            text: "·"
        }

        Text {
            font.pixelSize: constant.fontSizeDefault
            color: highlighted ? Theme.highlightColor : constant.colorLight
            text: link.commentsCount + " comments"
        }

    }
}
