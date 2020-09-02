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

    Flow {
        anchors { left: parent.left; right: parent.right }
        spacing: constant.paddingMedium

        Bubble {
            visible: link.flairText !== ""
            text: link.flairText
        }

        Bubble {
            color: "green"
            visible: !!link.isSticky
            text: qsTr("Sticky")
            font.bold: true
        }

        Bubble {
            color: "red"
            visible: !!link.isNSFW
            text: qsTr("NSFW")
            font.bold: true
        }

        Bubble {
            color: "green"
            visible: !!link.isPromoted
            text: qsTr("Promoted")
            font.bold: true
        }

        Bubble {
            visible: !!link.gilded && link.gilded > 0
            text: link.gilded > 1 ? qsTr("Gilded") + " " + link.gilded + "x" : qsTr("Gilded")
            color: "gold"
            font.bold: true
        }

        Bubble {
            color: constant.colorDisabled
            visible: !!link.isArchived
            text: qsTr("Archived")
            font.bold: true
        }

        Bubble {
            color: Qt.lighter("purple", 1.5)
            visible: !!link.isLocked
            text: qsTr("Locked")
            font.bold: true
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
        onLinkActivated: {
            if (link.indexOf("cross:") == 0) {
                console.log("fetching crossposts for " + link.substring(9))
                pageStack.push(Qt.resolvedUrl("MainPage.qml"), { duplicatesOf: link.substring(9) });
            } else
                globalUtils.openLink(link)
        }
        text: constant.richtextStyle +
              qsTr("submitted %1 by %2").arg(link.created).arg(
                (compact ? link.author : "<a href=\"https://reddit.com/u/" + link.author.split(" ")[0] + "\">" + link.author + "</a>") +
                (showSubreddit ?
                     " " + qsTr("to %1").arg((compact ? link.subreddit : "<a href=\"https://reddit.com/r/" + link.subreddit + "\">" + link.subreddit + "</a>"))
                     : "")) +
              ((!compact && link.crossposts > 0) ? ". <a href=\"cross:" + link.fullname + "\">" + qsTr("%n crossposts", "", link.crossposts) + "</a>" : "")
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
            text: (link.score < 0 ? "-" : "") + qsTr("%n points", "", Math.abs(link.score))
        }

        Text {
            font.pixelSize: constant.fontSizeDefault
            color: highlighted ? Theme.highlightColor : constant.colorLight
            text: "·"
        }

        Text {
            font.pixelSize: constant.fontSizeDefault
            color: highlighted ? Theme.highlightColor : constant.colorLight
            text: qsTr("%n comments", "", link.commentsCount)
        }

    }
}
