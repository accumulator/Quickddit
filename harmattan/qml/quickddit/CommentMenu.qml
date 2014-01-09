import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

ContextMenu {
    id: commentMenu

    property variant comment
    property string linkPermalink
    property VoteManager commentVoteManager

    // to ensure the dialog is destroy properly before position to parent
    property bool __showParentAtDestruction: false
    signal showParent
    signal replyClicked

    MenuLayout {
        MenuItem {
            id: upvoteButton
            visible: quickdditManager.isSignedIn && comment.likes != 1
            enabled: !commentVoteManager.busy
            text: "Upvote"
            onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Upvote)
        }
        MenuItem {
            visible: comment.likes != -1
            enabled: quickdditManager.isSignedIn && !commentVoteManager.busy
            text: "Downvote"
            platformStyle: MenuItemStyle { position: upvoteButton.visible ? "vertical-center" : "vertical-top" }
            onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Downvote)
        }
        MenuItem {
            visible: quickdditManager.isSignedIn && comment.likes != 0
            enabled: !commentVoteManager.busy
            text: "Unvote"
            onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Unvote)
        }
        MenuItem {
            visible: quickdditManager.isSignedIn && quickdditManager.isSignedIn
            text: "Reply"
            onClicked: replyClicked();
        }
        MenuItem {
            text: "Permalink"
            onClicked: {
                var link = QMLUtils.toAbsoluteUrl(linkPermalink + comment.fullname.substring(3));
                globalUtils.createOpenLinkDialog(link);
            }
        }
        MenuItem {
            enabled: comment.depth > 0
            text: "Parent"
            onClicked: __showParentAtDestruction = true;
        }
    }

    Component.onDestruction: {
        if (__showParentAtDestruction)
            showParent();
    }
}
