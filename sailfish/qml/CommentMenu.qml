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

FancyContextMenu {
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

    FancyMenuItemRow {
        FancyMenuItem {
            enabled: quickdditManager.isSignedIn && !commentVoteManager.busy
            text: comment.likes === 1 ? "Unvote" : "Upvote"
            onClicked: commentVoteManager.vote(comment.fullname,
                            comment.likes === 1 ? VoteManager.Unvote : VoteManager.Upvote)
        }
        FancyMenuItem {
            enabled: quickdditManager.isSignedIn && !commentVoteManager.busy
            text: comment.likes === -1 ? "Unvote" : "Downvote"
            onClicked: commentVoteManager.vote(comment.fullname,
                            comment.likes === -1 ? VoteManager.Unvote : VoteManager.Downvote)
        }
    }

    FancyMenuItemRow {
        FancyMenuItem {
            text: "Copy Comment"
            onClicked: {
                QMLUtils.copyToClipboard(comment.rawBody);
                infoBanner.alert(qsTr("Comment copied to clipboard"));
            }
        }

        FancyMenuItem {
            enabled: quickdditManager.isSignedIn
            text: "Reply"
            onClicked: replyClicked();
        }
    }

    FancyMenuItemRow {
        visible: comment.isAuthor

        FancyMenuItem {
            enabled: comment.isAuthor
            text: "Edit"
            onClicked: editClicked();
        }
        FancyMenuItem {
            enabled: comment.isAuthor
            text: "Delete"
            onClicked: deleteClicked();
        }
    }

    FancyMenuItemRow {
        FancyMenuItem {
            enabled: comment.depth > 0
            text: "Parent"
            onClicked: __showParentAtDestruction = true;
        }
        FancyMenuItem {
            text: "Permalink"
            onClicked: {
                var link = QMLUtils.toAbsoluteUrl(linkPermalink + comment.fullname.substring(3));
                globalUtils.createOpenLinkDialog(link);
            }
        }
    }

    Component.onDestruction: {
        if (__showParentAtDestruction)
            showParent();
    }
}
