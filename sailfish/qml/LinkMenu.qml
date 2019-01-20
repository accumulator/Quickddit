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
        visible: quickdditManager.isSignedIn && link.likes !== 1
        enabled: !linkVoteManager.busy && !link.isArchived
        text: qsTr("Upvote")
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Upvote)
    }
    MenuItem {
        visible: quickdditManager.isSignedIn && link.likes !== -1
        enabled: !linkVoteManager.busy && !link.isArchived
        text: qsTr("Downvote")
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Downvote)
    }
    MenuItem {
        visible: quickdditManager.isSignedIn && link.likes !== 0
        enabled: !linkVoteManager.busy && !link.isArchived
        text: qsTr("Unvote")
        onClicked: linkVoteManager.vote(link.fullname, VoteManager.Unvote)
    }
    MenuItem {
        text: qsTr("Save")
        visible: quickdditManager.isSignedIn && !link.saved
        enabled: !linkVoteManager.busy
        onClicked: linkSaveManager.save(link.fullname)
    }
    MenuItem {
        text: qsTr("Unsave")
        visible: quickdditManager.isSignedIn && link.saved
        enabled: !linkVoteManager.busy
        onClicked: linkSaveManager.unsave(link.fullname)
    }
    MenuItem {
        text: qsTr("URL")
        onClicked: globalUtils.createOpenLinkDialog(link.url);
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
