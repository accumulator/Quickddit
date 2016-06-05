/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

AbstractPage {
    id: newMessagePage
    title: "New Message"

    property string recipient
    property alias subject: subjectField.text
    property alias message: messageField.text
    property QtObject messageManager

    function send() {
        console.log("sending message...");
        messageManager.send(recipient, subjectField.text, messageField.text, captcha.userInput, captchaManager.iden);
    }

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: mainContentColumn.height

        Column {
            id: mainContentColumn
            width: parent.width
            spacing: constant.paddingMedium

            Label {
                anchors {right: parent.right; rightMargin: constant.paddingLarge }
                text: "to " + (recipient.indexOf("/r") == 0 ? "moderators of " : "") + recipient
                font.pixelSize: constant.fontSizeXSmall
                color: constant.colorLight
            }

            TextField {
                id: subjectField
                anchors { left: parent.left; right: parent.right }
                placeholderText: "Subject"
                maximumLength: 100 // reddit constraint
                focus: true
            }

            TextArea {
                id: messageField
                anchors { left: parent.left; right: parent.right }
                placeholderText: "Message"
                visible: enabled
                height: Math.max(implicitHeight, 300)
            }

            Captcha {
                id: captcha
                visible: captchaManager.captchaNeeded
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "Send"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: messageField.text.length > 0 && subjectField.text.length > 0
                         && (!captchaManager.captchaNeeded || captcha.userInput.length > 0)
                onClicked: send()
            }
        }
    }

}
