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
    id: userPage
    title: "User"
    busy: userManager.busy

    property string username;

    SilicaListView {
        id: userItemsListView
        anchors.fill: parent
        model: userThingModel

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                enabled: !userManager.busy
                onClicked: userManager.request(username);
            }
        }

        header: Column {
            width: parent.width
            anchors.margins: constant.paddingMedium

            spacing: 20

            QuickdditPageHeader { title: userPage.title }

            Text {
                anchors.left: parent.left
                anchors.margins: constant.paddingMedium
                color: constant.colorLight
                font.pixelSize: constant.fontSizeLarger
                font.bold: true
                text: "/u/" + userManager.user.name
            }

            Row {
                anchors.left: parent.left
                anchors.margins: constant.paddingMedium
                spacing: 20

                Bubble {
                    color: "green"
                    visible: !!userManager.user.isFriend
                    font.bold: true
                    text: "Friend"
                }
                Bubble {
                    visible: !!userManager.user.isGold
                    text: "Gold"
                }
                Bubble {
                    visible: !!userManager.user.hasVerifiedEmail
                    text: "Email Verified"
                }
                Bubble {
                    visible: !!userManager.user.isMod
                    text: "Mod"
                }
                Bubble {
                    visible: !!userManager.user.isHideFromRobots
                    text: "No Robots"
                }
            }

            Separator {
                anchors { left: parent.left; right: parent.right }
                color: constant.colorMid
            }

            Column {
                anchors.left: parent.left
                anchors.margins: constant.paddingMedium

                Text {
                    text: userManager.user.linkKarma + " link karma"
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeDefault
                }

                Text {
                    text: userManager.user.commentKarma + " comment karma"
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeDefault
                }

                Text {
                    text: "created " + userManager.user.created
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeDefault
                }
            }

            Separator {
                anchors { left: parent.left; right: parent.right }
                color: constant.colorMid
            }

            // spacer
            Rectangle {
                height: 10
                width: 1
                color: "transparent"
            }

        }

        delegate: Item {
            id: commentDelegate

            width: ListView.view.width
            height: mainItem.height

            signal clicked

            onClicked: {
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: "/r/" + model.subreddit + "/comments/" + model.linkId + "/" + model.fullname.substring(3)})
            }

            ListItem {
                id: mainItem
                width: commentDelegate.width

                contentHeight: mainColumn.height + 2 * constant.paddingMedium
                showMenuOnPressAndHold: false

                onClicked: commentDelegate.clicked()

                Column {
                    id: mainColumn
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingMedium
                    }
                    height: childrenRect.height
                    spacing: constant.paddingSmall

                    Row {
                        Text {
                            font.pixelSize: constant.fontSizeDefault
                            color: mainItem.enabled ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                                    : constant.colorDisabled
                            font.bold: true
                            text: "Comment in /r/" + model.subreddit
                        }
                        Text {
                            font.pixelSize: constant.fontSizeDefault
                            color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                                    : constant.colorDisabled
                            elide: Text.ElideRight
                            text: " · " + model.created
                        }
                    }

                    Text {
                        width: parent.width
                        font.pixelSize: constant.fontSizeSmaller
                        color: mainItem.enabled ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                                : constant.colorDisabled
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        text: model.linkTitle
                    }

                    WideText {
                        width: parent.width
                        body: model.body
                        listItem: mainItem
                        onClicked: commentDelegate.clicked()
                    }

                }
            }
        }

        footer: LoadingFooter { visible: userManager.busy; listViewItem: userItemsListView }

        ViewPlaceholder { enabled: userItemsListView.count == 0 && !userThingModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        userManager.request(username);
        userThingModel.username = username;
        userThingModel.refresh(false);
    }

    UserManager {
        id: userManager
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    UserThingModel {
        id: userThingModel
        manager: quickdditManager
    }
}
