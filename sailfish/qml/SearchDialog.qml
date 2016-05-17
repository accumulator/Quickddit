/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

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

AbstractDialog {
    id: searchDialog

    readonly property string title: "Search"
    property alias subreddit: subredditTextField.text

    acceptDestination: Qt.resolvedUrl("SearchPage.qml")
    acceptDestinationAction: PageStackAction.Replace
    canAccept: searchTextField.text.length > 0 && (!subredditTextField.enabled || subredditTextField.acceptableInput)

    onAccepted: {
        Qt.inputMethod.commit(); // not sure if this is needed
        if (searchSubredditSwitch.checked)
            acceptDestinationInstance.subreddit = subredditTextField.text
        acceptDestinationInstance.searchQuery = searchTextField.text;
        acceptDestinationInstance.refresh();
    }

    Column {
        anchors { left: parent.left; right: parent.right }
        height: childrenRect.height

        DialogHeader {
            title: searchDialog.title
            dialog: searchDialog
        }

        TextField {
            id: searchTextField
            anchors { left: parent.left; right: parent.right }
            placeholderText: "Enter search query"
            labelVisible: false
            EnterKey.enabled: searchDialog.canAccept
            EnterKey.iconSource: "image://theme/icon-m-search"
            EnterKey.onClicked: accept();
        }

        ComboBox {
            id: searchTypeComboBox
            anchors { left: parent.left; right: parent.right }
            label: "Search for"
            menu: ContextMenu {
                MenuItem { text: "Posts" }
                MenuItem { text: "Subreddits" }
            }
            onCurrentIndexChanged: {
                if (currentIndex == 0) {
                    acceptDestinationProperties = {}
                    acceptDestination = Qt.resolvedUrl("SearchPage.qml")
                } else {
                    acceptDestinationProperties = { isSearch: true }
                    acceptDestination = Qt.resolvedUrl("SubredditsBrowsePage.qml")
                }
            }
        }

        TextSwitch {
            id: searchSubredditSwitch
            anchors { left: parent.left; right: parent.right }
            enabled: searchTypeComboBox.currentIndex == 0
            text: "Search within this subreddit:"
        }

        TextField {
            id: subredditTextField
            anchors { left: parent.left; right: parent.right }
            enabled: searchSubredditSwitch.enabled && searchSubredditSwitch.checked
            opacity: enabled ? 1 : 0.4
            errorHighlight: enabled && !acceptableInput
            placeholderText: "Enter subreddit name"
            labelVisible: false
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            validator: RegExpValidator { regExp: /^([A-Za-z0-9][A-Za-z0-9_]{2,20}|[a-z]{2})$/ }
            EnterKey.enabled: searchDialog.canAccept
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: searchDialog.accept();
        }
    }

    Component.onCompleted: searchSubredditSwitch.checked = (subreddit !== "")
}
