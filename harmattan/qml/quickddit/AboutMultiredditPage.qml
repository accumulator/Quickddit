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

AbstractPage {
    id: aboutMultiredditPage

    property alias multireddit: multiredditManager.name
    property alias model: multiredditManager.model

    title: "About /m/" + multiredditManager.name
    busy: multiredditManager.busy
    onHeaderClicked: flickable.contentY = 0;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-add"
            opacity: enabled ? 1 : 0.25
            enabled: multiredditManager.canEdit && !multiredditManager.busy
            onClicked: {
                var dialog = addSubredditSheetComponent.createObject(aboutMultiredditPage);
                dialog.statusChanged.connect(function() {
                    if (dialog.status == DialogStatus.Closed) {
                        dialog.destroy(250);
                    }
                });
                dialog.accepted.connect(function() {
                    multiredditManager.addSubreddit(dialog.subreddit);
                });
                dialog.open();
            }
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: flickableColumn.height

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            SectionHeader { title: "Description" }

            Text {
                id: descriptionText
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.italic: multiredditManager.description.length == 0
                text: multiredditManager.description || "No description"
            }

            SectionHeader { title: "Subreddits" }

            // use another column for zero spacing
            Column {
                anchors { left: parent.left; right: parent.right }
                height: childrenRect.height

                Repeater {
                    id: subredditsRepeater
                    anchors { left: parent.left; right: parent.right }
                    model: multiredditManager.subreddits
                    delegate: SimpleListItem {
                        width: subredditsRepeater.width
                        menu: subredditMenuComponent
                        text: "/r/" + modelData
                        onClicked: showMenu({subreddit: modelData});
                    }
                }
            }
        }
    }

    Component {
        id: subredditMenuComponent

        ContextMenu {
            id: subredditMenu

            property string subreddit

            MenuLayout {
                MenuItem {
                    text: "Go to /r/" + subredditMenu.subreddit
                    onClicked: {
                        var mainPage = pageStack.find(function(p) { return p.objectName == "mainPage"; });
                        mainPage.refresh(subredditMenu.subreddit);
                        pageStack.pop(mainPage);
                    }
                }
                MenuItem {
                    text: "Remove"
                    enabled: multiredditManager.canEdit && !multiredditManager.busy
                    onClicked: multiredditManager.removeSubreddit(subredditMenu.subreddit);
                }
            }
        }
    }

    Component {
        id: addSubredditSheetComponent

        Sheet {
            id: addSubredditSheet
            acceptButtonText: (subredditTextField.acceptableInput && subreddit.length > 0) ? "Add" : ""
            rejectButtonText: "Cancel"

            property alias subreddit: subredditTextField.text

            content: Column {
                anchors {
                    left: parent.left; right: parent.right; top: parent.top
                    margins: constant.paddingMedium
                }
                height: childrenRect.height
                spacing: constant.paddingLarge

                Text {
                    anchors { left: parent.left; right: parent.right }
                    font.pixelSize: constant.fontSizeXLarge
                    color: constant.colorLight
                    text: "Add Subreddit"
                }

                TextField {
                    id: subredditTextField
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: "Enter subreddit name"
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    validator: RegExpValidator { regExp: /^([A-Za-z0-9][A-Za-z0-9_]{2,20}|[a-z]{2})$/ }
                    platformSipAttributes: SipAttributes {
                        actionKeyEnabled: addSubredditSheet.acceptButton.enabled
                        actionKeyLabel: addSubredditSheet.acceptButtonText
                    }
                    onAccepted: addSubredditSheet.accept();
                }
            }
        }

        Component.onCompleted: subredditTextField.focus = true;
    }

    AboutMultiredditManager {
        id: multiredditManager
        manager: quickdditManager
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.alert(errorString);
    }
}
