/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import quickddit.Core 1.0
import QtGraphicalEffects 1.0

Row {
    id:bottomRow

    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager

    ToolButton {
        id:up
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/10
        icon.name: "go-up-symbolic"
        icon.color: link.likes ===1 ? persistantSettings.greenColor : persistantSettings.textColor

        onClicked: {
            if (link.likes ===1)
                linkVoteManager.vote(link.fullname, VoteManager.Unvote)
            else
                linkVoteManager.vote(link.fullname, VoteManager.Upvote)
        }
    }

    Label {
        id:score
        height: parent.height
        width: parent.width/5
        horizontalAlignment: "AlignHCenter"
        verticalAlignment: "AlignVCenter"
        text: link.score
        font.weight: Font.Normal
        color: link.score>0 ? persistantSettings.greenColor : link.score<0 ? persistantSettings.redColor : persistantSettings.textColor
    }
    ToolButton {
        id:down
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/10
        icon.name: "go-down-symbolic"
        icon.color: link.likes ===-1 ? persistantSettings.redColor : persistantSettings.textColor

        onClicked: {
            if (link.likes ===-1)
                linkVoteManager.vote(link.fullname, VoteManager.Unvote)
            else
                linkVoteManager.vote(link.fullname, VoteManager.Downvote)
        }
    }

    ToolButton {
        id: comment
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/5
        icon.name: "comment-symbolic"
        text: link.commentsCount

        onClicked: {
            if (compact){
                var p = { link: link };
                pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/CommentPage.qml"), p);
            }
        }
    }

    ToolButton {
        id:share
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/5
        icon.name: "emblem-shared-symbolic"

        onClicked: {
            QMLUtils.copyToClipboard(link.url)
            infoBanner.alert(qsTr("Link coppied to clipboard"))
            icon.color = persistantSettings.primaryColor
        }

        onPressAndHold: {
            QMLUtils.copyToClipboard("https://reddit.com"+link.permalink)
            infoBanner.alert(qsTr("Permalink coppied to clipboard"))
            icon.color = persistantSettings.primaryColor
        }
    }

    ToolButton {
        id:save
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/5
        enabled: quickdditManager.isSignedIn
        icon.name: link.saved ? "starred-symbolic" : "non-starred-symbolic"
        icon.color: link.saved ? persistantSettings.primaryColor : persistantSettings.textColor

        onClicked: {
            linkSaveManager.save(link.fullname,!link.saved)
        }
    }
}
