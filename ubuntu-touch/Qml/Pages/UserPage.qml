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
import "../"
import "../Delegates"

Page {
    title: "/u/"+username;

    property string username;
    property bool myself: appSettings.redditUsername === username && username !== ""

    ListView {
        anchors.fill: parent
        header: Column {
            width: parent.width
            Row {
                width: parent.width
                CircleImage {
                    source: userManager.user.iconImg
                    width: Math.min(150,parent.width/4)
                    height: width
                }

                Label {
                    anchors.bottom: parent.bottom
                    padding: 10
                    text: "/u/"+username
                    font.pointSize: 18
                }
            }
            Row {
                anchors.right: parent.right
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 5
                    text: userManager.user.linkKarma+" link / " +userManager.user.commentKarma+" comment karma"
                }
                Button {
                    text: qsTr("Send message")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SendMessagePage.qml"),
                                       {messageManager: messageManager, recipient: username});
                    }

                }
            }
        }

        model: userThingModel
        delegate: Component {

            Loader {
                id:delegateLoader

                property variant item: model
                property int listIndex: index
                width: parent.width

                sourceComponent: model.kind === "t1" ? commentDelegateComponent
                                                     : model.kind === "t3" ? linkDelegateComponent : undefined

            }
        }

        Component {
            id: commentDelegateComponent
            UserPageCommentDelegate {
                property int index: listIndex

                model: !!item ? item.comment : undefined
                markSaved: userThingModel.section !== UserThingModel.SavedSection
                onClicked: {
                    // context needs the double slash '//' in the path
                    pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/CommentPage.qml"), {
                                       linkPermalink: "/r/" + model.subreddit + "/comments/" + model.linkId + "//" + model.fullname.substring(3) + "?context=8",
                                       linkSaveManager: linkSaveManager
                                   });
                }
            }
        }

        Component {
            id: linkDelegateComponent
            UserPageLinkDelegate {
                id: linkDelegate
                property int index: listIndex

                model: !!item ? item.link : undefined
                markSaved: userThingModel.section !== UserThingModel.SavedSection
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/CommentPage.qml"), {
                                       linkPermalink: "/r/" + model.subreddit + "/comments/" + model.fullname.substring(3),
                                       linkSaveManager: linkSaveManager
                                   });
                }
            }
        }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !userThingModel.busy && userThingModel.canLoadMore)
                userThingModel.refresh(true);
        }

    }

    Component.onCompleted: {
        userManager.request(username);
        userThingModel.username = username;
        //userThingModel.refresh(false);
    }

    UserManager {
        id: userManager
        manager: quickdditManager
        onError: infoBanner.warning(errorString);
        onBusyChanged: {
            if(!busy){
                userThingModel.refresh(false);
            }
        }
    }

    UserThingModel {
        id: userThingModel
        manager: quickdditManager
        section: myself ? UserThingModel.SavedSection : UserThingModel.OverviewSection
        onError: infoBanner.warning(errorString);
    }

    LinkManager {
        id: linkManager
        manager: quickdditManager
        userThingModel: userThingModel
        onSuccess: infoBanner.alert(message);
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
        onSuccess: infoBanner.alert("TODO: update userpage model");
        onError: infoBanner.warning(errorString);
    }
}
