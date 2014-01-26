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
    id: messagePage
    title: "Messages - " + sectionModel[messageModel.section]
    busy: messageModel.busy || messageManager.busy

    readonly property variant sectionModel: ["All", /*"Unread",*/ "Message", "Comment Replies", "Post Replies", "Sent"]

    SilicaListView {
        id: messageListView
        anchors.fill: parent
        model: messageModel

        PullDownMenu {
            MenuItem {
                text: "Section"
                onClicked: {
                    globalUtils.createSelectionDialog("Section", sectionModel, messageModel.section,
                    function(selectedIndex) {
                        messageModel.section = selectedIndex;
                        messageModel.refresh(false);
                    });
                }
            }
            MenuItem {
                text: "Refresh"
                enabled: !messageModel.busy
                onClicked: messageModel.refresh(false);
            }
        }

        header: PageHeader { title: messagePage.title }

        delegate: MessageDelegate {
            isSentMessage: messageModel.section == MessageModel.SentSection
            menu: Component { MessageMenu {} }
            showMenuOnPressAndHold: false
            onClicked: {
                if (model.isComment) {
                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: model.context})
                } else if (!isSentMessage) {
                    var dialog = pageStack.push(Qt.resolvedUrl("TextAreaDialog.qml"), {titleText: "Reply Message"});
                    dialog.accepted.connect(function() {
                        messageManager.reply(model.fullname, dialog.text);
                    });
                }
            }
            onPressAndHold: showMenu({message: model, messageManager: messageManager, enableMarkRead: !isSentMessage})
        }

        LoadMoreMenu {
            visible: messageListView.count > 0
            loadMoreVisible: messageModel.canLoadMore
            loadMoreEnabled: !messageModel.busy
            onClicked: messageModel.refresh(true);
        }

        ViewPlaceholder { enabled: messageListView.count == 0 && !messageModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    MessageModel {
        id: messageModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    MessageManager {
        id: messageManager
        manager: quickdditManager
        onReplySuccess: infoBanner.alert("Message sent");
        onMarkReadStatusSuccess: messageModel.changeIsUnread(fullname, isUnread);
        onError: infoBanner.alert(errorString);
    }
}
