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

ContextMenu {
    id: linkMenu

    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager

    signal deleteLink
    signal hideLink

    MenuItem {
        id: upvoteButton
        visible: link.likes !== 1
        enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
        text: qsTr("Upvote")
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Upvote)
    }
    MenuItem {
        visible: link.likes !== -1
        enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
        text: qsTr("Downvote")
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Downvote)
    }
    MenuItem {
        visible: link.likes !== 0
        enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
        text: qsTr("Unvote")
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Unvote)
    }
    MenuItem {
        text: qsTr("View image")
        visible: globalUtils.previewableImage(link.url)
        onClicked: globalUtils.openImageViewPage(link.url);
    }
    MenuItem {
        text: qsTr("Save")
        visible: !link.saved
        onClicked: linkSaveManager.save(link.fullname)
    }
    MenuItem {
        text: qsTr("Unsave")
        visible: link.saved
        onClicked: linkSaveManager.unsave(link.fullname)
    }
    MenuItem {
        text: qsTr("URL")
        onClicked: globalUtils.createOpenLinkDialog(link.url);
    }
    MenuItem {
        text: qsTr("Delete")
        visible: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived && link.author === appSettings.redditUsername
        onClicked: deleteLink()
    }
    MenuItem {
        text: qsTr("Hide")
        visible: quickdditManager.isSignedIn && !linkVoteManager.busy
        onClicked: hideLink()
    }

}
