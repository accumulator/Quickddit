/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2015-2016  Sander van Grieken

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
    title: "User /u/" + username

    property string username;

    property bool myself: appSettings.redditUsername === username && username !== ""

    readonly property variant sectionModel: [qsTr("Overview"), qsTr("Comments"), qsTr("Submitted")]
    readonly property variant sectionModelMy: [qsTr("Overview"), qsTr("Comments"), qsTr("Submitted"), qsTr("Upvoted"), qsTr("Downvoted"), qsTr("Saved Things")]

    SilicaListView {
        id: userItemsListView
        anchors.fill: parent
        model: userThingModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Section")
                onClicked: {
                    globalUtils.createSelectionDialog(qsTr("Section"), myself ? sectionModelMy : sectionModel, userThingModel.section,
                    function(selectedIndex) {
                        userThingModel.section = selectedIndex;
                        userThingModel.refresh(false);
                    });
                }
            }
            MenuItem {
                text: qsTr("Send Message")
                visible: !myself
                enabled: !messageManager.busy && quickdditManager.isSignedIn
                onClicked: {
                    var p = {messageManager: messageManager, recipient: username};
                    pageStack.push(Qt.resolvedUrl("SendMessagePage.qml"), p);
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                enabled: !userManager.busy
                onClicked: userThingModel.refresh(false);
            }
        }

        header: Column {
            width: parent.width
            anchors.margins: constant.paddingMedium

            spacing: 20

            QuickdditPageHeader { title: (myself ? qsTr("My Profile") : qsTr("User Profile")) + " - " + sectionModelMy[userThingModel.section] }

            Row {
                visible: userThingModel.section === UserThingModel.OverviewSection
                anchors.left: parent.left
                anchors.margins: constant.paddingMedium

                Image {
                    source: "image://theme/icon-m-person"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeLarger
                    font.bold: true
                    text: "/u/" + username
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Flow {
                visible: userThingModel.section === UserThingModel.OverviewSection
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: constant.paddingMedium
                spacing: 20

                Bubble {
                    color: "green"
                    visible: !!userManager.user.isFriend
                    font.bold: true
                    text: qsTr("Friend")
                }
                Bubble {
                    visible: !!userManager.user.isGold
                    text: qsTr("Gold")
                }
                Bubble {
                    visible: !!userManager.user.hasVerifiedEmail
                    text: qsTr("Email Verified")
                }
                Bubble {
                    visible: !!userManager.user.isMod
                    text: qsTr("Mod")
                }
                Bubble {
                    visible: !!userManager.user.isHideFromRobots
                    text: qsTr("No Robots")
                }
            }

            Separator {
                visible: userThingModel.section === UserThingModel.OverviewSection
                anchors { left: parent.left; right: parent.right }
                color: constant.colorMid
            }

            Column {
                id: aboutColumn
                visible: userThingModel.section === UserThingModel.OverviewSection
                anchors.left: parent.left
                anchors.margins: constant.paddingMedium

                function object_or(o,d) { return (!!o ? o : d) }

                Text {
                    text: aboutColumn.object_or(userManager.user.linkKarma,0) + " link karma"
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeDefault
                }

                Text {
                    text: aboutColumn.object_or(userManager.user.commentKarma,0) + " comment karma"
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeDefault
                }

                Text {
                    text: "created " + aboutColumn.object_or(userManager.user.created,"?")
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeDefault
                }
            }

            Separator {
                visible: userThingModel.section === UserThingModel.OverviewSection
                anchors { left: parent.left; right: parent.right }
                color: constant.colorMid
            }
        }

        delegate: Component {
            Loader {
                id: delegateLoader
                width: parent.width

                property variant item: model
                property int listIndex: index

                sourceComponent: model.kind === "t1" ? commentDelegate
                                                     : model.kind === "t3" ? linkDelegate : undefined
            }
        }

        Component {
            id: commentDelegate
            UserPageCommentDelegate {
                property int index: listIndex

                model: !!item ? item.comment : undefined
                markSaved: userThingModel.section !== UserThingModel.SavedSection
                onClicked: {
                    // context needs the double slash '//' in the path
                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {
                                       linkPermalink: "/r/" + model.subreddit + "/comments/" + model.linkId + "//" + model.fullname.substring(3) + "?context=8",
                                       linkSaveManager: linkSaveManager
                                   });
                }

                AltMarker { }
            }
        }

        Component {
            id: linkDelegate
            UserPageLinkDelegate {
                property int index: listIndex

                model: !!item ? item.link : undefined
                markSaved: userThingModel.section !== UserThingModel.SavedSection
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {
                                       linkPermalink: "/r/" + model.subreddit + "/comments/" + model.fullname.substring(3),
                                       linkSaveManager: linkSaveManager
                                   });
                }

                AltMarker { }
            }
        }

        footer: LoadingFooter {
            listViewItem: userItemsListView
            visible: userThingModel.busy || (userItemsListView.count > 0 && userThingModel.canLoadMore)
            running: userThingModel.busy
        }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !userThingModel.busy && userThingModel.canLoadMore)
                userThingModel.refresh(true);
        }

        ViewPlaceholder { enabled: userItemsListView.count == 0 && !userThingModel.busy; text: qsTr("Nothing here :(") }

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
        onError: infoBanner.warning(errorString);
    }

    UserThingModel {
        id: userThingModel
        manager: quickdditManager
        section: myself ? UserThingModel.SavedSection : UserThingModel.OverviewSection
        onError: infoBanner.warning(errorString);
    }

    MessageManager {
        id: messageManager
        manager: quickdditManager
        onSendSuccess: {
            infoBanner.alert(qsTr("Message sent"));
            pageStack.pop();
        }
        onError: infoBanner.warning(errorString);
    }

    SaveManager {
        id: linkSaveManager
        manager: quickdditManager
        onSuccess: console.log("TODO: update userpage model");
        onError: infoBanner.warning(errorString);
    }

}
