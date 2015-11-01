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
    id: messagePage
    title: "Messages - " + sectionModel[messageModel.section]
    busy: messageManager.busy
    onHeaderClicked: messageListView.positionViewAtBeginning();

    property variant sectionModel: ["All", "Unread", "Message", "Comment Replies", "Post Replies", "Sent"]
    property Component __textAreaDialogComponent: null

    function __createTextAreaDialog(title) {
        if (!__textAreaDialogComponent)
            __textAreaDialogComponent = Qt.createComponent("TextAreaDialog.qml");
        var dialog = __textAreaDialogComponent.createObject(messagePage, {title: title});
        dialog.statusChanged.connect(function() {
            if (dialog.status == DialogStatus.Closed) {
                dialog.destroy(250);
            }
        });
        dialog.open();
        return dialog;
    }

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: {
                globalUtils.createSelectionDialog("Section", sectionModel, messageModel.section,
                function(selectedIndex) {
                    messageModel.section = selectedIndex;
                    messageModel.refresh(false);
                })
            }
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: messageModel.refresh(false);
        }
    }

    ListView {
        id: messageListView
        anchors.fill: parent
        model: messageModel

        delegate: MessageDelegate {
            isSentMessage: messageModel.section == MessageModel.SentSection
            menu: Component { MessageMenu {} }
            onClicked: {
                messageManager.markRead(model.fullname)
                if (model.isComment) {
                    pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: model.context})
                } else if (!isSentMessage) {
                    var dialog = __createTextAreaDialog("Reply Message");
                    dialog.accepted.connect(function() {
                        messageManager.reply(model.fullname, dialog.text);
                    });
                }
            }
            onPressAndHold: showMenu({message: model, messageManager: messageManager, enableMarkRead: !isSentMessage})
        }

        footer: LoadingFooter { visible: messageModel.busy; listViewItem: messageListView }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !messageModel.busy && messageModel.canLoadMore)
                messageModel.refresh(true);
        }

        ViewPlaceholder { enabled: messageListView.count == 0 && !messageModel.busy }
    }

    ScrollDecorator { flickableItem: messageListView }

    MessageModel {
        id: messageModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    MessageManager {
        id: messageManager
        manager: quickdditManager
        onReplySuccess: infoBanner.alert("Message sent");
        onMarkReadStatusSuccess: messageModel.changeIsUnread(fullname, isUnread);
        onError: infoBanner.alert(errorString);
    }
}
