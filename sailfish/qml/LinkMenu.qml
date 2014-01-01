import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

ContextMenu {
    id: linkMenu

    property variant link
    property VoteManager linkVoteManager

    MenuItem {
        id: upvoteButton
        visible: quickdditManager.isSignedIn && link.likes != 1
        enabled: !linkVoteManager.busy
        text: "Upvote"
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Upvote)
    }
    MenuItem {
        visible: quickdditManager.isSignedIn && link.likes != -1
        enabled: !linkVoteManager.busy
        text: "Downvote"
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Downvote)
    }
    MenuItem {
        visible: quickdditManager.isSignedIn && link.likes != 0
        enabled: !linkVoteManager.busy
        text: "Unvote"
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Unvote)
    }
    MenuItem {
        text: "View image"
        enabled: {
            if (link.domain == "i.imgur.com" || link.domain == "imgur.com")
                return true;
            if (/^https?:\/\/.+\.(jpe?g|png|gif)/i.test(link.url))
                return true;
            else
                return false;
        }
        onClicked: {
            var p = {};
            if (link.domain == "imgur.com")
                p.imgurUrl = link.url;
            else
                p.imageUrl = link.url;
            pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), p);
        }
    }
    MenuItem {
        text: "URL"
        onClicked: globalUtils.createOpenLinkDialog(link.url);
    }

}
