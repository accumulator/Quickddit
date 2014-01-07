import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

ContextMenu {
    id: commentMenu

    property variant comment
    property string linkPermalink
    property VoteManager commentVoteManager

    // when the menu is closing SilicaListView will override the contentY causes the positioning to failed
    // position at menu destruction to fix this
    property bool __showParentAtDestruction: false
    signal showParent

    MenuItem {
        id: upvoteButton
        visible: quickdditManager.isSignedIn && comment.likes != 1
        enabled: !commentVoteManager.busy
        text: "Upvote"
        onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Upvote)
    }
    MenuItem {
        visible: quickdditManager.isSignedIn && comment.likes != -1
        enabled: !commentVoteManager.busy
        text: "Downvote"
        onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Downvote)
    }
    MenuItem {
        visible: quickdditManager.isSignedIn && comment.likes != 0
        enabled: !commentVoteManager.busy
        text: "Unvote"
        onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Unvote)
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

    Component.onDestruction: {
        if (__showParentAtDestruction)
            showParent();
    }
}
