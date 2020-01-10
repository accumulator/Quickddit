/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2017  Sander van Grieken

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
    id: linkMenu

    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager

    signal deleteLink
    signal hideLink

    FancyMenuItemRow {
        FancyMenuImage {
            enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
            highlighted: link.likes === 1
            icon: "image://theme/icon-m-up"
            onClicked: linkVoteManager.vote(link.fullname,
                            link.likes === 1 ? VoteManager.Unvote : VoteManager.Upvote)
        }
        FancyMenuImage {
            enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
            highlighted: link.likes === -1
            icon: "image://theme/icon-m-down"
            onClicked: linkVoteManager.vote(link.fullname,
                            link.likes === -1 ? VoteManager.Unvote : VoteManager.Downvote)
        }
        FancyMenuImage {
            icon: globalUtils.previewableVideo(link.url) ? "image://theme/icon-m-video" :
                  globalUtils.redditLink(link.url) ? "image://theme/icon-m-forward" :
                  globalUtils.previewableImage(link.url) ? "image://theme/icon-m-image" :
                  "image://theme/icon-m-website"
            enabled: !globalUtils.redditLink(link.url) || link.permalink.indexOf(globalUtils.parseRedditLink(link.url).path) === -1 // self-post, but not this one
            onClicked: {
                if (globalUtils.previewableVideo(link.url)) {
                    globalUtils.openVideoViewPage(link.url);
                } else if (globalUtils.previewableImage(link.url)) {
                    globalUtils.openImageViewPage(link.url);
                } else if (globalUtils.redditLink(link.url)) {
                    globalUtils.openRedditLink(link.url);
                } else {
                    pageStack.push(globalUtils.getWebViewPage(), {url: link.url});
                }
            }
        }
        FancyMenuImage {
            icon: "image://theme/icon-m-link"
            onClicked: globalUtils.openNonPreviewLink(link.url, link.permalink);
        }
        FancyMenuImage {
            enabled: quickdditManager.isSignedIn && !linkSaveManager.busy
            icon: link.saved ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            onClicked: linkSaveManager.save(link.fullname, !link.saved);
        }
    }

    MenuItem {
        text: qsTr("Delete")
        visible: quickdditManager.isSignedIn && !link.isArchived && link.author === appSettings.redditUsername
        enabled: !linkVoteManager.busy
        onClicked: deleteLink()
    }
    MenuItem {
        text: qsTr("Hide")
        visible: quickdditManager.isSignedIn
        enabled: !linkVoteManager.busy
        onClicked: hideLink()
    }

}
