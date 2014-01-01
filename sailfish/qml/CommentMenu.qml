import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

ContextMenu {
    id: commentMenu

    property variant comment
    property string linkPermalink
    property VoteManager commentVoteManager

    signal positionToParent

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
            var link = QMLUtils.getRedditFullUrl(linkPermalink + comment.fullname.substring(3));
            globalUtils.createOpenLinkDialog(link);
        }
    }
    // positioning listview when menu is closing is not working
//    MenuItem {
//        enabled: comment.depth > 0
//        text: "Parent"
//        onClicked: positionToParent();
//    }

}
