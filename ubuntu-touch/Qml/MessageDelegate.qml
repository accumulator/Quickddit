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

SwipeDelegate {
    id: messageDelegate
    height: info.height + title.height + linkTit.height + body.height

    leftPadding: 0
    topPadding: 0

    Connections {
        target: messageListView

        onMovementStarted: messageDelegate.swipe.close()
    }

    swipe.left: ActionButton {
        ico: "../Icons/delete.svg"
        visible: !model.isComment
        enabled: !messageManager.busy

        onClicked: {
            messageManager.del(model.fullname);
            swipe.close()
        }
    }

    swipe.right: Row {
        anchors { top: parent.top;bottom: parent.bottom; right: parent.right }

        ActionButton {
            ico: model.isUnread? "../Icons/mail-read.svg" :"../Icons/mail-unread.svg"
            enabled: !messageManager.busy

            onClicked: {
                model.isUnread ? messageManager.markRead(model.fullname)
                               : messageManager.markUnread(model.fullname);
                swipe.close();
            }
        }

        ActionButton {
            ico: "../Icons/mail-reply.svg"
            visible: !model.isComment
            enabled: !messageManager.busy && model.author !== appSettings.redditUsername

            onClicked: {
                if (model.author !== appSettings.redditUsername) {
                    messageDelegate.doReply()
                }
                swipe.close()
            }
        }
    }

    contentItem: Item {
        height: parent.height
        width: parent.width
    Label {
        id:info
        anchors {left: parent.left;right: parent.right;top: parent.top }
        padding: 5
        text: isComment ? "<a href='r/" + model.subreddit + "'>"+"r/"+model.subreddit + "</a> ~ " + model.created
                        : (model.author === appSettings.redditUsername)
                          ? model.destination
                          : (model.author !== "")
                            ? model.author + " ~ " + model.created
                            : "r/" + model.subreddit + " ~ " + model.created
        onLinkActivated: pageStack.push(Qt.resolvedUrl("SubredditPage.qml"),{subreddit:link.slice(2)})
    }

    Label {
        id:title
        anchors {top: info.bottom; left: parent.left; right: parent.right }
        padding: 3
        font.pointSize: 12
        font.weight: Font.DemiBold
        wrapMode: Text.Wrap
        text: isComment ? qsTr("%1 from %2").arg(model.subject).arg(model.author)
                        : model.subject
    }

    Label {
        id:linkTit
        anchors {top: title.bottom; left: parent.left; right: parent.right }
        height: visible ? contentHeight+10 : 0
        padding: 5
        wrapMode: Text.WordWrap
        font.pointSize: 10
        visible: text.length > 0
        text: model.linkTitle
    }

    Row {
        anchors { top:linkTit.bottom; left: parent.left; right: parent.right }
        width: parent.width
        height: body.height
        leftPadding: 5
        Rectangle {
            id:rect
            width: model.isUnread ? 5:2
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height-6
            color: "#ef9928"
        }

        Label {
            id:body
            width: parent.width-rect.width
            padding: 5
            text: model.body
            textFormat: Text.StyledText
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            onLinkActivated: {
                globalUtils.openLink(link)
            }
        }
    }

    }
}
