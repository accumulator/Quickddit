import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

ContextMenu {
    id: commentDialog

    property variant comment
    property string linkPermalink
    property VoteManager commentVoteManager

    property bool __isClosing: false

    signal positionToParent

    MenuLayout {
        MenuItem {
            id: upvoteButton
            visible: comment.likes != 1
            enabled: !commentVoteManager.busy
            text: "Upvote"
            onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Upvote)
        }
        MenuItem {
            visible: comment.likes != -1
            enabled: !commentVoteManager.busy
            text: "Downvote"
            platformStyle: MenuItemStyle { position: upvoteButton.visible ? "vertical-center" : "vertical-top" }
            onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Downvote)
        }
        MenuItem {
            visible: comment.likes != 0
            enabled: !commentVoteManager.busy
            text: "Unvote"
            onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Unvote)
        }
        MenuItem {
            text: "Permalink"
            onClicked: {
                var link = QMLUtils.getRedditFullUrl(linkPermalink + comment.fullname.substring(3));
                globalDialogManager.createOpenLinkDialog(commentPage, link);
            }
        }
        MenuItem {
            enabled: comment.depth > 0
            text: "Parent"
            onClicked: positionToParent();
        }
    }

    Component.onCompleted: open();

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) commentDialog.destroy(250)
    }
}
