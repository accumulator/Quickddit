/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
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
    id: messagePage
    objectName: "messagePage"
    title: "Messages - " + sectionModel[messageModel.section]
    busy: messageManager.busy

    function refresh() {
        messageModel.refresh(false);
        inboxManager.dismiss();
    }

    readonly property variant sectionModel: ["All", "Unread", "Message", "Comment Replies", "Post Replies", "Sent"]

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
                        messagePage.refresh();
                    });
                }
            }
            MenuItem {
                text: "Refresh"
                enabled: !messageModel.busy
                onClicked: messagePage.refresh();
            }
        }

        header: QuickdditPageHeader { title: messagePage.title }

        delegate: MessageDelegate {
            width: parent.width

            isSentMessage: messageModel.section == MessageModel.SentSection

            listItem.menu: Component { MessageMenu {} }
            listItem.showMenuOnPressAndHold: false
            listItem.onPressAndHold: listItem.showMenu({message: model, messageManager: messageManager, enableMarkRead: !isSentMessage})

            onClicked: {
                messageManager.markRead(model.fullname)
                if (model.isComment) {
                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: model.context})
                } else if (!isSentMessage) {
                    var dialog = pageStack.push(Qt.resolvedUrl("TextAreaDialog.qml"), {title: "Reply Message"});
                    dialog.accepted.connect(function() {
                        messageManager.reply(model.fullname, dialog.text);
                    });
                }
            }

            AltMarker { }
        }

        footer: LoadingFooter {
            visible: messageModel.busy || (messageListView.count > 0 && messageModel.canLoadMore)
            running: messageModel.busy
            listViewItem: messageListView
        }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !messageModel.busy && messageModel.canLoadMore)
                messageModel.refresh(true);
        }

        ViewPlaceholder { enabled: messageListView.count == 0 && !messageModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    MessageModel {
        id: messageModel
        manager: quickdditManager
        onError: infoBanner.warning(errorString)
    }

    MessageManager {
        id: messageManager
        manager: quickdditManager
        onReplySuccess: {
            infoBanner.alert("Message sent");
            inboxManager.resetTimer();
        }
        onMarkReadStatusSuccess: messageModel.changeIsUnread(fullname, isUnread);
        onError: infoBanner.warning(errorString);
    }

    Component.onCompleted: {
        inboxManager.dismiss();
    }
}
