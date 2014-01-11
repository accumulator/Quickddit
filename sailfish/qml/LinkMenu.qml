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
