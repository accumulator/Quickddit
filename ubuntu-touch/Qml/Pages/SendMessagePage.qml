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
import "../"

Page {
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

    Flickable {
        id: flickable
        anchors { fill: parent; margins: 10 }
        contentHeight: mainContentColumn.height

        Column {
            id: mainContentColumn
            width: parent.width
            spacing: 5

            TextField {
                id: recipientField
                visible: recipient === ""
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Recipient")
                maximumLength: 100 // reddit constraint
            }

            Label {
                anchors {right: parent.right; rightMargin: 5 }
                text: (recipient.indexOf("/r") == 0 ? qsTr("to moderators of") : qsTr("to")) + " " + recipient
                font.pointSize: 10
                visible : recipient !== ""
            }

            TextField {
                id: subjectField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Subject")
                maximumLength: 100 // reddit constraint
                enabled: replyTo === ""
            }

            RichTextEditor {
                id: messageField
                anchors { left: parent.left; right: parent.right }
                visible: enabled
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Button {
                    text: qsTr("Send")
                    enabled: messageField.text.length > 0 && (subjectField.text.length > 0 || replyTo != "")
                             && (recipient !== "" || recipientField.text.length > 0)
                    onClicked: send(recipient === "" ? recipientField.text : recipient)
                }

                Button {
                    id: cancelBtn
                    text: qsTr("Cancel")
                    onClicked: pageStack.pop()
                }
            }
        }
    }
}
