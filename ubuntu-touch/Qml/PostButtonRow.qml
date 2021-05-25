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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import quickddit.Core 1.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Suru 2.2

Row{
    id:bottomRow

    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager

    ActionButton {
        id:up
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        ico: "qrc:/Icons/up.svg"
        color: link.likes ===1 ? Suru.color(Suru.Green,1) : Suru.foregroundColor

        onClicked: {
            if (link.likes ===1)
                linkVoteManager.vote(link.fullname, VoteManager.Unvote)
            else
                linkVoteManager.vote(link.fullname, VoteManager.Upvote)
        }
    }

    Label{
        id:score
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        text: link.score
        font.weight: Font.Normal
        horizontalAlignment: "AlignHCenter"
        color:  link.score>0 ? Suru.color(Suru.Green,1) : link.score<0 ? Suru.color(Suru.Red,1) : Suru.foregroundColor
    }
    ActionButton {
        id:down
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        ico: "qrc:/Icons/down.svg"
        color: link.likes ===-1 ? Suru.color(Suru.Red,1) : Suru.foregroundColor

        onClicked: {
            if (link.likes ===-1)
                linkVoteManager.vote(link.fullname, VoteManager.Unvote)
            else
                linkVoteManager.vote(link.fullname, VoteManager.Downvote)
        }
    }

    ToolButton {
        id:comment
        width: parent.width/6
        anchors.verticalCenter: parent.verticalCenter
        flat: true
        hoverEnabled: false
        onClicked: {
            if (compact){
                var p = { link: link };
                pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/CommentPage.qml"), p);
            }
        }
        Row {
            id:row
            anchors.centerIn: parent

            Image{
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/Icons/message.svg"
                width: Suru.units.gu(3)
                height: Suru.units.gu(3)
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: Suru.foregroundColor
                }
            }
            Label{
                anchors.verticalCenter: parent.verticalCenter
                text: " "+link.commentsCount
                color: Suru.foregroundColor
            }
        }
    }

    ActionButton {
        id:share
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        ico: "qrc:/Icons/edit-copy.svg"
        color: Suru.foregroundColor

        onClicked: {
            QMLUtils.copyToClipboard(link.url)
            infoBanner.alert(qsTr("Link coppied to clipboard"))
        }

        onPressAndHold: {
            QMLUtils.copyToClipboard("https://reddit.com"+link.permalink)
            infoBanner.alert(qsTr("Permalink coppied to clipboard"))
        }
    }

    ActionButton {
        id:save
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        enabled: quickdditManager.isSignedIn
        ico: link.saved ? "qrc:/Icons/starred.svg" : "qrc:/Icons/non-starred.svg"
        color: link.saved ? Suru.color(Suru.Orange,1) : Suru.foregroundColor

        onClicked: {
            linkSaveManager.save(link.fullname,!link.saved)
        }
    }
}
