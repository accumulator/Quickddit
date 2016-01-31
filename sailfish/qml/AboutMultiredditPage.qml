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
import harbour.quickddit.Core 1.0

AbstractPage {
    id: aboutMultiredditPage
    title: "About /m/" + multiredditManager.name
    busy: multiredditManager.busy

    property alias multireddit: multiredditManager.name
    property alias model: multiredditManager.model

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: flickableColumn.height

        PullDownMenu {
            MenuItem {
                text: "Add Subreddit"
                enabled: multiredditManager.canEdit && !multiredditManager.busy
                onClicked: {
                    var dialog = pageStack.push(addSubredditDialogComponent);
                    dialog.accepted.connect(function() {
                        multiredditManager.addSubreddit(dialog.subreddit);
                    });
                }
            }
        }

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right }
            height: childrenRect.height

            PageHeader { title: aboutMultiredditPage.title }

            SectionHeader { text: "Description" }

            Text {
                id: descriptionText
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                font.italic: multiredditManager.description.length == 0
                text: multiredditManager.description ? "<style>a { color: " + Theme.highlightColor + "; }</style>" + multiredditManager.description : "No description"
                onLinkActivated: globalUtils.openLink(link);
            }

            SectionHeader { text: "Subreddits" }

            Repeater {
                id: subredditsRepeater
                anchors { left: parent.left; right: parent.right }
                model: multiredditManager.subreddits
                delegate: SimpleListItem {
                    showMenuOnPressAndHold: false
                    width: subredditsRepeater.width
                    menu: subredditMenuComponent
                    text: "/r/" + modelData
                    onClicked: showMenu({subreddit: modelData});
                    onPressAndHold: showMenu({subreddit: modelData});
                }
            }
        }
    }

    Component {
        id: subredditMenuComponent

        ContextMenu {
            id: subredditMenu

            property string subreddit

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

    Component {
        id: addSubredditDialogComponent

        Dialog {
            id: addSubredditDialog

            property alias subreddit: subredditTextField.text

            canAccept: subredditTextField.acceptableInput

            Column {
                id: dialogColumn
                anchors { left: parent.left; right: parent.right }
                spacing: constant.paddingMedium

                DialogHeader { title: "Add Subreddit" }

                TextField {
                    id: subredditTextField
                    anchors { left: parent.left; right: parent.right }
                    placeholderText: "Enter subreddit name"
                    labelVisible: false
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    validator: RegExpValidator { regExp: /^[A-Za-z0-9][A-Za-z0-9_]{2,20}$/ }
                    EnterKey.enabled: addSubredditDialog.canAccept
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: addSubredditDialog.accept();
                }
            }
        }
    }

    AboutMultiredditManager {
        id: multiredditManager
        manager: quickdditManager
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.warning(errorString);
    }
}
