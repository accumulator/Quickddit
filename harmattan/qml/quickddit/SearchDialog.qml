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

import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: searchDialog
    acceptButtonText: "Search"
    acceptButton.enabled: (searchTextField.text.length > 0 || searchTextField.platformPreedit.length > 0)
                          && (!subredditTextField.enabled || subredditTextField.acceptableInput)
    rejectButtonText: "Cancel"

    property alias text: searchTextField.text
    property int type: 0
    property bool searchSubreddit: searchSubredditCheckBox.checked
    property alias subreddit: subredditTextField.text

    onAccepted: searchTextField.parent.focus = true; // force commit of predictive text

    content: Column {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
        height: childrenRect.height
        spacing: constant.paddingLarge

        TextField {
            id: searchTextField
            placeholderText: "Enter search query"
            anchors { left: parent.left; right: parent.right }
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: searchDialog.acceptButton.enabled
                actionKeyLabel: searchDialog.acceptButtonText
            }
            onAccepted: searchDialog.accept();
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: "Search for:"
        }

        ButtonRow {
            id: typeButtonRow
            anchors { left: parent.left; right: parent.right }
            onCheckedButtonChanged: {
                if (checkedButton == searchButton) searchDialog.type = 0;
                else searchDialog.type = 1;
            }

            Button {
                id: searchButton
                text: "Posts"
            }

            Button {
                id: subredditButton
                text: "Subreddits"
            }
        }

        CheckBox {
            id: searchSubredditCheckBox
            anchors { left: parent.left; right: parent.right }
            enabled: searchButton.checked
            checked: subreddit != "" ? true : false
            text: "Search within this subreddit:"
        }

        TextField {
            id: subredditTextField
            anchors { left: parent.left; right: parent.right }
            enabled: searchSubredditCheckBox.enabled && searchSubredditCheckBox.checked
            opacity: enabled ? 1 : 0.75
            errorHighlight: enabled && !acceptableInput
            placeholderText: "Enter subreddit name"
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            validator: RegExpValidator { regExp: /^[A-Za-z0-9][A-Za-z0-9_]{2,20}$/ }
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: searchDialog.acceptButton.enabled
                actionKeyLabel: searchDialog.acceptButtonText
            }
            onAccepted: searchDialog.accept();
        }
    }
}
