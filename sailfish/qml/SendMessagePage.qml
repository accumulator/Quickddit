/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016-2018  Sander van Grieken

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
import harbour.quickddit.Core 1.0

AbstractPage {
    id: newMessagePage
    title: replyTo === "" ? qsTr("New Message") : qsTr("Reply Message")

    property string recipient: ""
    property alias subject: subjectField.text
    property alias message: messageField.text
    property string replyTo: ""
    property QtObject messageManager

    function send(msgRecipient) {
        console.log("sending message to " + msgRecipient + "...");
        if (replyTo === "") {
            messageManager.send(msgRecipient, subjectField.text, messageField.text);
        } else {
            messageManager.reply(replyTo, messageField.text);
        }
    }

    Component.onCompleted: {
        // set focus
        if (recipient === "") {
            recipientField.focus = true
        } else if (replyTo === "" && subject === "") {
            subjectField.focus = true
        } else
            messageField.focus = true
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: mainContentColumn.height

        Column {
            id: mainContentColumn
            width: parent.width
            spacing: constant.paddingMedium

            QuickdditPageHeader { title: newMessagePage.title }

            TextField {
                id: recipientField
                visible: recipient === ""
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Recipient")
                maximumLength: 100 // reddit constraint
                labelVisible: false
            }

            Label {
                anchors {right: parent.right; rightMargin: Theme.paddingLarge }
                text: (recipient.indexOf("/r") == 0 ? qsTr("to moderators of") : qsTr("to")) + " " + recipient
                font.pixelSize: constant.fontSizeXSmall
                color: Theme.highlightColor
                visible : recipient !== ""
            }

            TextField {
                id: subjectField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Subject")
                maximumLength: 100 // reddit constraint
                labelVisible: false
                enabled: replyTo === ""
            }

            TextArea {
                id: messageField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Message")
                visible: enabled
                height: Math.max(implicitHeight, Theme.itemSizeLarge * 3)
            }

            Button {
                text: qsTr("Send")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: messageField.text.length > 0 && (subjectField.text.length > 0 || replyTo != "")
                         && (recipient !== "" || recipientField.text.length > 0)
                onClicked: send(recipient === "" ? recipientField.text : recipient)
            }
        }
    }

}
