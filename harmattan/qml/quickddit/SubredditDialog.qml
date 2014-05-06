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
import Quickddit.Core 1.0

Sheet {
    id: subredditDialog
    acceptButtonText: "Go"
    acceptButton.enabled: subredditTextField.acceptableInput
    rejectButtonText: "Cancel"

    property SubredditModel subredditModel

    property alias text: subredditTextField.text
    property bool browseSubreddits: false

    content: Item {
        anchors.fill: parent

        TextField {
            id: subredditTextField
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            placeholderText: "Go to specific subreddit..."
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            // RegExp based on <https://github.com/reddit/reddit/blob/aae622d/r2/r2/lib/validator/validator.py#L525>
            validator: RegExpValidator { regExp: /^[A-Za-z0-9][A-Za-z0-9_]{2,20}$/ }
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: subredditDialog.acceptButton.enabled
                actionKeyLabel: subredditDialog.acceptButtonText
            }
            onAccepted: subredditDialog.accept();
        }

        Column {
            id: mainOptionColumn
            anchors {
                left: parent.left; right: parent.right
                top: subredditTextField.bottom; topMargin: constant.paddingMedium
            }
            height: childrenRect.height

            Repeater {
                id: mainOptionRepeater
                anchors { left: parent.left; right: parent.right }
                model: ["All", "Browse for Subreddits..."]

                SimpleListItem {
                    width: mainOptionRepeater.width
                    text: modelData
                    onClicked: {
                        switch (index) {
                        case 0: subredditDialog.text = "all"; break;
                        case 1: browseSubreddits = true; break;
                        }
                        subredditDialog.accept();
                    }
                }
            }
        }

        Item {
            id: subscribedSubredditHeader
            anchors { top: mainOptionColumn.bottom; left: parent.left; right: parent.right }
            height: constant.headerHeight
            visible: !!subredditModel

            Text {
                id: headerTitleText
                anchors {
                    left: parent.left; right: refreshItem.left; margins: constant.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                font.bold: true
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                elide: Text.ElideRight
                text: "Subscribed Subreddits"
            }

            Image {
                id: refreshItem
                anchors {
                    right: parent.right; margins: constant.paddingMedium; verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-toolbar-refresh" + (subredditModel && subredditModel.busy ? "-dimmed" : "")
                        + (appSettings.whiteTheme ? "" : "-white")

                MouseArea {
                    anchors.fill: parent
                    enabled: !!subredditModel && !subredditModel.busy
                    onClicked: subredditModel.refresh(false);
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: constant.colorMid
            }
        }

        ListView {
            id: subscribedSubredditListView
            anchors {
                top: subscribedSubredditHeader.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }
            visible: !!subredditModel
            clip: true
            model: visible ? subredditModel : 0
            delegate: SimpleListItem {
                text: model.url
                onClicked: {
                    subredditDialog.text = model.displayName;
                    subredditDialog.accept();
                }
            }

            footer: LoadingFooter {
                visible: !!subredditModel && subredditModel.busy
                listViewItem: subscribedSubredditListView
            }

            onAtYEndChanged: {
                if (atYEnd && count > 0 && !subredditModel.busy && subredditModel.canLoadMore)
                    subredditModel.refresh(true);
            }
        }

        ScrollDecorator { flickableItem: subscribedSubredditListView }
    }
}
