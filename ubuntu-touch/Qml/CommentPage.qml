/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import quickddit.Core 1.0

Page {
    id:commentPage
    title:commentModel.link.title

    property alias link: commentModel.link
    property alias linkPermalink: commentModel.permalink
    property VoteManager linkVoteManager1
    property SaveManager linkSaveManager1

    function refresh(refreshOlder) {
        commentModel.refresh(refreshOlder);
    }

    readonly property variant commentSortModel: [qsTr("Best"), qsTr("Top"), qsTr("New"), qsTr("Hot"), qsTr("Controversial"), qsTr("Old")]

    function loadMoreChildren(index, children) {
        commentModel.moreComments(index, children);
    }

    ListView {
        id:commentsList
        anchors.fill: parent
        header: LinkDelegate {
            width: parent.width
            link: commentModel.link
            compact: false
            linkVoteManager: linkVoteManager1
            linkSaveManager: linkSaveManager1
        }

        model: commentModel
        delegate: CommentDelegate {
            id:commentDelegate
            width: parent.width
        }
        footer: Item {
            width: parent.width
            height: 400
        }

    }

    CommentModel {
        id: commentModel
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.alert(errorString)
        onCommentLoaded: {
            var rlink = globalUtils.parseRedditLink(permalink)
            var post = rlink.path.split("/").pop()
            var postIndex = commentModel.getCommentIndex("t1_" + post);
            if (postIndex !== -1) {
                commentListView.model = commentModel
                commentListView.positionViewAtIndex(postIndex, ListView.Contain);
                commentListView.currentIndex = postIndex;
                commentListView.currentItem.highlight();
            }
        }
        onBusyChanged: {
            if(!busy){
                commentModel.showNewComment();
            }
        }
    }

    CommentManager {
        id: commentManager
        manager: quickdditManager
        model: commentModel
        linkAuthor: link ? link.author : ""
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.warning(errorString);
    }

    LinkManager {
        id: linkManager
        manager: quickdditManager
        commentModel: commentModel
        onSuccess: {
            infoBanner.alert(message);
            pageStack.pop();
        }
        onError: infoBanner.warning(errorString);
    }

    VoteManager {
        id: commentVoteManager
        manager: quickdditManager
        onVoteSuccess: {
            if (fullname.indexOf("t1") === 0) // comment
                commentModel.changeLikes(fullname, likes);
            else if (fullname.indexOf("t3") === 0) // link
                commentModel.changeLinkLikes(fullname, likes);
        }
        onError: infoBanner.warning(errorString);
    }

    SaveManager {
        id: commentSaveManager
        manager: quickdditManager
        onSuccess: {
            if (fullname.indexOf("t1") === 0) // comment
                commentModel.changeSaved(fullname, saved);
            else if (fullname.indexOf("t3") === 0) // link
                commentModel.changeLinkSaved(fullname, saved);
        }
        onError: infoBanner.warning(errorString);
    }

    Connections {
        target: linkVoteManager1
        onVoteSuccess: if (linkVoteManager1 != commentVoteManager) { commentModel.changeLinkLikes(fullname, likes); }
    }

    Connections {
        target: linkSaveManager1
        onSuccess: if (linkSaveManager1 != commentSaveManager) { commentModel.changeLinkSaved(fullname, saved); }
    }

    Component.onCompleted: {
        // if we didn't get vote and save managers passed (for updating models in the calling page),
        // we use the local managers
        if (!linkVoteManager1)
            linkVoteManager1 = commentVoteManager;
        if (!linkSaveManager1)
            linkSaveManager1 = commentSaveManager;
    }
}
