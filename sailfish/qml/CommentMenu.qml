/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2017  Sander van Grieken

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

FancyContextMenu {
    id: commentMenu

    property variant comment
    property variant post
    property VoteManager commentVoteManager
    property SaveManager commentSaveManager

    // when the menu is closing SilicaListView will override the contentY causes the positioning to failed
    // position at menu destruction to fix this
    property bool __showParentAtDestruction: false
    signal showParent
    signal replyClicked
    signal editClicked
    signal deleteClicked

    FancyMenuItemRow {
        FancyMenuImage {
            enabled: quickdditManager.isSignedIn && !commentVoteManager.busy && !comment.isArchived && comment.isValid
            highlighted: comment.likes === 1
            icon: "image://theme/icon-m-up"
            onClicked: commentVoteManager.vote(comment.fullname,
                            comment.likes === 1 ? VoteManager.Unvote : VoteManager.Upvote)
        }
        FancyMenuImage {
            enabled: quickdditManager.isSignedIn && !commentVoteManager.busy && !comment.isArchived && comment.isValid
            highlighted: comment.likes === -1
            icon: "image://theme/icon-m-down"
            onClicked: commentVoteManager.vote(comment.fullname,
                            comment.likes === -1 ? VoteManager.Unvote : VoteManager.Downvote)
        }
        FancyMenuImage {
            enabled: comment.depth > 0
            icon: "image://theme/icon-m-page-up"
            onClicked: __showParentAtDestruction = true;
        }
        FancyMenuImage {
            icon: "image://theme/icon-m-link"
            onClicked: {
                var link = QMLUtils.toAbsoluteUrl(post.permalink + comment.fullname.substring(3));
                globalUtils.createOpenLinkDialog(link);
            }
        }
        FancyMenuImage {
            enabled: quickdditManager.isSignedIn && !commentSaveManager.busy
            icon: comment.saved ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            onClicked: commentSaveManager.save(comment.fullname, !comment.saved);
        }
    }

    FancyMenuItemRow {
        visible: comment.isValid

        FancyMenuItem {
            text: qsTr("Copy Comment")
            onClicked: {
                QMLUtils.copyToClipboard(comment.rawBody);
                infoBanner.alert(qsTr("Comment copied to clipboard"));
            }
        }

        FancyMenuItem {
            enabled: quickdditManager.isSignedIn && !comment.isArchived && comment.isValid && !post.isLocked
            text: qsTr("Reply")
            onClicked: replyClicked();
        }
    }

    FancyMenuItemRow {
        visible: comment.isAuthor && !comment.isArchived

        FancyMenuItem {
            enabled: comment.isAuthor
            text: qsTr("Edit")
            onClicked: editClicked();
        }
        FancyMenuItem {
            enabled: comment.isAuthor
            text: qsTr("Delete")
            onClicked: deleteClicked();
        }
    }

    MenuItem {
        visible: comment.isValid

        text: "/u/" + comment.author.split(" ")[0]
        onClicked: {
            pageStack.push(Qt.resolvedUrl("UserPage.qml"), { username: comment.author.split(" ")[0] } );
        }
    }
    
     MenuItem {
        visible: !comment.isValid && (comment.rawBody === "[removed]" || comment.rawBody === "[deleted]")
        text: "Uncensor"
        onClicked: {
                var link = "https://www.removeddit.com" + post.permalink + comment.fullname.substring(3);
                globalUtils.createOpenLinkDialog(link);
            }
        }

    Component.onDestruction: {
        if (__showParentAtDestruction)
            showParent();
    }
}
