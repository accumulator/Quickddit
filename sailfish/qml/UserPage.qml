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
    title: "/u/" + username
    busy: userManager.busy

    property string username;

    SilicaListView {
        id: userItemsListView
        anchors.fill: parent
        //model: messageModel

        PullDownMenu {
            MenuItem {
                text: "Refresh"
                enabled: !userManager.busy
                onClicked: userManager.request(username);
            }
        }

        header: Column {
            PageHeader { title: "/u/" + userManager.user.name }

            Text {
                text: "link karma: " + userManager.user.linkKarma
                color: constant.colorLight
            }

            Text {
                text: "comment karma: " + userManager.user.commentKarma
                color: constant.colorLight
            }

            Text {
                text: "created: " + userManager.user.created
                color: constant.colorLight
            }

            Bubble {
                color: "green"
                visible: !!userManager.user.isFriend
                text: "Friend"
            }
            Bubble {
                color: "yellow"
                visible: !!userManager.user.isGold
                text: "Gold"
            }
            Bubble {
                color: "blue"
                visible: !!userManager.user.hasVerifiedEmail
                text: "Email Verified"
            }
            Bubble {
                color: "purple"
                visible: !!userManager.user.isMod
                text: "Mod"
            }

            Bubble {
                color: "grey"
                visible: !!userManager.user.isHideFromRobots
                text: "No Robots"
            }
        }

//        delegate: MessageDelegate {
//            isSentMessage: messageModel.section == MessageModel.SentSection
//            menu: Component { MessageMenu {} }
//            showMenuOnPressAndHold: false
//            onClicked: {
//                messageManager.markRead(model.fullname)
//                if (model.isComment) {
//                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: model.context})
//                } else if (!isSentMessage) {
//                    var dialog = pageStack.push(Qt.resolvedUrl("TextAreaDialog.qml"), {title: "Reply Message"});
//                    dialog.accepted.connect(function() {
//                        messageManager.reply(model.fullname, dialog.text);
//                    });
//                }
//            }
//            onPressAndHold: showMenu({message: model, messageManager: messageManager, enableMarkRead: !isSentMessage})
//        }

        footer: LoadingFooter { visible: userManager.busy; listViewItem: userItemsListView }

//        onAtYEndChanged: {
//            if (atYEnd && count > 0 && !messageModel.busy && messageModel.canLoadMore)
//                messageModel.refresh(true);
//        }

//        ViewPlaceholder { enabled: messageListView.count == 0 && !messageModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        userManager.request(username);
    }

    UserManager {
        id: userManager
        manager: quickdditManager
//        onSuccess: infoBanner.alert(message);
        onError: infoBanner.alert(errorString);
    }


}
