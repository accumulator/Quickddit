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
import quickddit.Core 1.0

Page {
    id: newLinkPage
    title: editPost === "" ? qsTr("New Post") : qsTr("Edit Post")

    property string subreddit
    property string editPost: ""
    property alias text: linkDescription.text
    property alias postTitle: linkTitle.text
    property alias postUrl: linkUrl.text
    property QtObject linkManager

    property string origText: ""
    property string origFlair: ""

    function submit() {
        if (editPost === "") {
            console.log(qsTr("submitting post..."));
            var flairId = ""
            if (flairCombo.currentIndex >= 0)
                flairId = flairManager.subredditFlairs[flairCombo.currentIndex].id
            linkManager.submit(subreddit, linkTitle.text, selfLinkSwitch.checked ? "" : linkUrl.text, linkDescription.text, flairId);
        } else {
            console.log(qsTr("saving post..."));
            if (origText !== text) {
                linkManager.editLinkText(editPost, text);
            }
            var newFlair = flairCombo.currentIndex >= 0 ? flairManager.subredditFlairs[flairCombo.currentIndex].text : ""
            var newFlairId = flairCombo.currentIndex >= 0 ? flairManager.subredditFlairs[flairCombo.currentIndex].id : ""
            if (origFlair !== newFlair) {
                flairManager.selectFlair(linkManager.commentModel.link.fullname, newFlairId)
            }
        }
    }

    Flickable {
        id: scrollView
        anchors.fill: parent
        contentHeight: mainContentColumn.height
        contentWidth: width

        Column {
            id: mainContentColumn
            width: parent.width
            spacing: 10

            Label {
                anchors {right: parent.right; }
                text: "/r/" + subreddit
            }

            TextField {
                id: linkTitle
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Post Title")
                enabled: editPost === ""
            }

            CheckBox {
                id: selfLinkSwitch
                visible: aboutSubredditManager.submissionType === AboutSubredditManager.Any && editPost === ""
                text: qsTr("Self Post")
                checked: linkUrl.text === ""
            }

            TextField {
                id: linkUrl
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Post URL")
                enabled: !selfLinkSwitch.checked && editPost === ""
                visible: !selfLinkSwitch.checked
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                validator: RegExpValidator { regExp: /^https?:\/\/.+/ }
                //errorHighlight: activeFocus && !acceptableInput
            }

            TextArea {
                id: linkDescription
                anchors { left: parent.left; right: parent.right }
                placeholderText: qsTr("Post Text")
                wrapMode: TextEdit.WordWrap
                enabled: selfLinkSwitch.checked
                visible: enabled
            }

            ComboBox {
                id: flairCombo
                //label: qsTr("Flair")
                enabled: flairManager.subredditFlairs.length > 0
                visible: enabled
                model: {flairManager.subredditFlairs}
                textRole: "text"
                onModelChanged: {
                    currentIndex = -1
                }
            }

            Button {
                text: editPost === "" ? qsTr("Submit") : qsTr("Save")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: (editPost != "" || linkTitle.text.length > 0) /* official limits? */
                         && ((selfLinkSwitch.checked && linkDescription.text.length > 0) || (!selfLinkSwitch.checked && linkUrl.acceptableInput))
                onClicked: submit()
            }
        }
    }

    Component.onCompleted: {
        origText = newLinkPage.text
        aboutSubredditManager.refresh();
    }

    AboutSubredditManager {
        id: aboutSubredditManager
        manager: quickdditManager
        subreddit: newLinkPage.subreddit
        onError: infoBanner.warning(errorString)
        onDataChanged: {
            if (submissionType === AboutSubredditManager.Link)
                selfLinkSwitch.checked = false
            flairManager.getSubredditFlair();
        }
    }

    FlairManager {
        id: flairManager
        manager: quickdditManager
        subreddit: newLinkPage.subreddit
        onError: infoBanner.warning(errorString);
        onSubredditFlairsChanged: {
            if (newLinkPage.editPost === "")
                return
            for (var index = 0;index < subredditFlairs.length; index++) {
                if (linkManager.commentModel.link.flairText === subredditFlairs[index].text) {
                    flairCombo.currentIndex = index
                    origFlair = subredditFlairs[index].text
                }
            }
        }
    }
}
