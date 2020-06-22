import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

Page {
    title: "Messages"
    ListView {
        id: messageListView
        anchors.fill: parent
        model: messageModel

        delegate: MessageDelegate {

            width: parent.width
            onClicked: {
                if (model.isComment) {
                    doOpenComment()
                } else if (model.author !== appSettings.redditUsername) {
                    doReply()
                }
            }

            function doOpenComment() {
                if (model.isUnread) {
                    messageManager.markRead(model.fullname)
                }
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: model.context})
            }

            function doReply() {
                if (model.isUnread) {
                    messageManager.markRead(model.fullname)
                }
                pageStack.push(Qt.resolvedUrl("SendMessagePage.qml"),
                               {messageManager: messageManager, replyTo: model.fullname, recipient: model.author !== "" ? model.author : "/r/" + model.subreddit, subject: "re: " + model.subject});
            }
        }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !messageModel.busy && messageModel.canLoadMore)
                messageModel.refresh(true);
        }
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
            infoBanner.alert(qsTr("Message sent"));
            pageStack.pop();
        }
        onSendSuccess: {
            infoBanner.alert(qsTr("Message sent"));
            pageStack.pop();
        }
        onMarkReadStatusSuccess: messageModel.changeIsUnread(fullname, isUnread);
        onDelSuccess: messageModel.del(fullname);
        onError: infoBanner.warning(errorString);
    }

    Component.onCompleted: {
        //inboxManager.dismiss();
    }
}
