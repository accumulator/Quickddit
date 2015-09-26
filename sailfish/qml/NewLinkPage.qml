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
import harbour.quickddit.Core 1.0

AbstractPage {
    id: newLinkPage
    title: "New Post"

    property string subreddit
    property QtObject linkManager

    function submit() {
        console.log("submitting link...");
        linkManager.submit(subreddit, captcha.userInput, captchaManager.iden, linkTitle.text, selfLinkSwitch.checked ? "" : linkUrl.text, linkDescription.text);
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: mainContentColumn.height

        Column {
            id: mainContentColumn
            width: parent.width
            spacing: constant.paddingMedium

            PageHeader { title: newLinkPage.title }

            Label {
                anchors {right: parent.right; rightMargin: Theme.paddingLarge }
                text: "/r/" + subreddit
                font.pixelSize: constant.fontSizeXSmall
                color: Theme.highlightColor
            }

            TextField {
                id: linkTitle
                anchors { left: parent.left; right: parent.right }
                placeholderText: "Post Title"
                labelVisible: false
            }

            TextSwitch {
                id: selfLinkSwitch
                text: "Self Post"
                checked: true
            }

            TextField {
                id: linkUrl
                anchors { left: parent.left; right: parent.right }
                placeholderText: "Post URL"
                enabled: !selfLinkSwitch.checked
                visible: enabled
                labelVisible: false
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                validator: RegExpValidator { regExp: /^https?:\/\/.+/ }
                errorHighlight: activeFocus && !acceptableInput
            }

            TextArea {
                id: linkDescription
                anchors { left: parent.left; right: parent.right }
                placeholderText: "Post Description"
                enabled: selfLinkSwitch.checked
                visible: enabled
                height: Math.max(implicitHeight, Theme.itemSizeLarge * 3)
            }

            Captcha {
                id: captcha
                visible: captchaManager.captchaNeeded
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "Submit"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: linkTitle.text.length > 0 /* official limits? */
                         && (!captchaManager.captchaNeeded || captcha.userInput.length > 0)
                         && ((selfLinkSwitch.checked && linkDescription.text.length > 0) || linkUrl.acceptableInput)
                onClicked: submit()
            }
        }
    }

}
