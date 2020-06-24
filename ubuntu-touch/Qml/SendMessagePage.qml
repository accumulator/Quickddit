import QtQuick 2.9
import QtQuick.Controls 2.2

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
        anchors.fill: parent
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

            TextArea {
                id: messageField
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Message")
                visible: enabled
                //height: Math.max(implicitHeight, Theme.itemSizeLarge * 3)
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
