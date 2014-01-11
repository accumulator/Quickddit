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

ContextMenu {
    id: commentMenu

    property variant comment
    property string linkPermalink
    property VoteManager commentVoteManager

    // to ensure the dialog is destroy properly before position to parent
    property bool __showParentAtDestruction: false
    signal showParent
    signal replyClicked
    signal editClicked
    signal deleteClicked

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
    }

    Component.onDestruction: {
        if (__showParentAtDestruction)
            showParent();
    }
}
