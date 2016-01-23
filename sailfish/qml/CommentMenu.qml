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

ContextMenu {
    id: commentMenu

    property variant comment
    property string linkPermalink
    property VoteManager commentVoteManager

    // when the menu is closing SilicaListView will override the contentY causes the positioning to failed
    // position at menu destruction to fix this
    property bool __showParentAtDestruction: false
    signal showParent
    signal replyClicked
    signal editClicked
    signal deleteClicked

    MenuItem {
        id: upvoteButton
        visible: comment.likes !== 1
        enabled: quickdditManager.isSignedIn && !commentVoteManager.busy
        text: "Upvote"
        onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Upvote)
    }
    MenuItem {
        visible: comment.likes !== -1
        enabled: quickdditManager.isSignedIn && !commentVoteManager.busy
        text: "Downvote"
        onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Downvote)
    }
    MenuItem {
        visible: comment.likes !== 0
        enabled: quickdditManager.isSignedIn && !commentVoteManager.busy
        text: "Unvote"
        onClicked: commentVoteManager.vote(comment.fullname, VoteManager.Unvote)
    }
    MenuItem {
        enabled: quickdditManager.isSignedIn
        text: "Reply"
        onClicked: replyClicked();
    }
    MenuItem {
        visible: comment.isAuthor
        text: "Edit"
        onClicked: editClicked();
    }
    MenuItem {
        visible: comment.isAuthor
        text: "Delete"
        onClicked: deleteClicked();
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

    MenuItem {
        text: "Copy Comment"
        onClicked: {
            QMLUtils.copyToClipboard(comment.rawBody);
            infoBanner.alert(qsTr("Comment copied to clipboard"));
        }
    }

    MenuItem {
        text: comment.author.split(" ")[0]
        onClicked: {
            pageStack.push(Qt.resolvedUrl("UserPage.qml"), { username: comment.author.split(" ")[0] } );
        }
    }

    Component.onDestruction: {
        if (__showParentAtDestruction)
            showParent();
    }
}
