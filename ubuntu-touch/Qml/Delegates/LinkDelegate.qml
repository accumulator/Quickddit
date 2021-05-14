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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import quickddit.Core 1.0
import QtGraphicalEffects 1.0

import "../"

ItemDelegate {
    id:linkDelegate

    visible: !(!persistantSettings.enableNSFW && link.isNSFW)
    property bool compact: true
    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager
    property bool previewableImage: globalUtils.previewableImage(link.url)
    property bool previewableVideo: globalUtils.previewableVideo(link.url)
    property alias activeManager: pic.activeManager
    property alias imageUrl: pic.imageUrl

    height: visible ? Math.max(titulok.height+pic.height+flairs.height,txt.height+titulok.height+flairs.height,thumb.height)+info.height+bottomRow.height : 0

    onClicked: {
        if(!compact&&link.domain.slice(5)!==link.subreddit)
            if(previewableImage) {
                globalUtils.openLink(pic.imageUrl)
            }
            else
                globalUtils.openLink(link.url)
    }

    //info
    Label {
        id: info
        padding: 5
        anchors {top: parent.top; left: parent.left; right: parent.right; }
        elide: Text.ElideRight
        linkColor: persistantSettings.primaryColor
        text: "<a href='/r/"+link.subreddit+"'>"+"/r/"+link.subreddit+"</a>"+" ~ <a href='/u/"+link.author+"'>"+"/u/"+link.author+"</a>"+" ~ "+link.created+" ~ "+link.domain+((!compact && link.crossposts > 0) ? ". <a href=\"cross:" + link.fullname + "\">" + qsTr("%n crossposts", "", link.crossposts) + "</a>" : "")
        onLinkActivated: {
            if (link.indexOf("cross:") == 0) {
                console.log("fetching crossposts for " + link.substring(9))
                pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/MainPage.qml"), { duplicatesOf: link.substring(9) });
            }
            else if(link.charAt(1)=='r')
                pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SubredditPage.qml"),{subreddit:link.slice(3)})
            else if(link.charAt(1)=='u')
                pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/UserPage.qml"),{username:link.slice(3).split(" ")[0]})
        }
    }
    ListView {
        id: flairs
        anchors {top: info.bottom; left:thumb.visible ? thumb.right : parent.left; leftMargin: 5 }
        height: count ? currentItem.height : 0
        width: contentWidth
        orientation: ListView.Horizontal
        clip: true
        spacing: 5
        delegate: Loader {
            active: modelData != ""
            sourceComponent: Flair { text: modelData }

        }
        model: [link.flairText,
            !!link.isSticky ? qsTr("Sticky") : "",
            !!link.isNSFW ? qsTr("NSFW") : "",
            !!link.isPromoted ? qsTr("Promoted") : "",
            !!link.gilded ? qsTr("Gilded") + (link.gilded > 1 ? " " + link.gilded + "x": "") : "",
            !!link.isArchived ? qsTr("Archived") : "",
            !!link.isLocked ? qsTr("Locked") : ""].filter(removeEmpty)

        function removeEmpty(value) {
            return value !== ""
        }
    }

    //title
    Label {
        padding: 5
        anchors {top: flairs.bottom; right: parent.right; left:thumb.visible ? thumb.right : parent.left }
        id: titulok
        text: link.title
        elide: Text.ElideRight
        maximumLineCount: compact && !thumb.visible ? 3 : 9999
        height: thumb.visible && compact ? thumb.height - flairs.height : implicitHeight
        font.pointSize: 12
        font.weight: Font.DemiBold
        wrapMode: Text.Wrap
    }
    //text
    Label {
        id:txt
        padding: 5

        anchors.right: parent.right
        anchors.top: titulok.bottom
        anchors.left: parent.left
        height: text ? implicitHeight : 0
        text: compact ? link.text : "<style>a {color:  " + persistantSettings.primaryColor + " }</style>\n"+link.text
        linkColor: persistantSettings.primaryColor
        elide: Text.ElideRight
        maximumLineCount: compact ? 3:9999
        wrapMode: Text.WordWrap
        textFormat: compact ? Text.StyledText : Text.RichText
        onLinkActivated: globalUtils.openLink(link)
    }
    //preview
    Thumbnail {
        id:thumb
        anchors {left: parent.left; top:info.bottom; leftMargin: 5 }
        video: previewableVideo
        image: previewableImage
        urlPost: !globalUtils.redditLink(link.url)&&!video&&!image
        link: linkDelegate.link
        visible: urlPost || (image && persistantSettings.compactImages && compact) || (video && persistantSettings.compactVideos)
    }

    //image
    AlbumView {
        id: pic
        anchors.top: titulok.bottom
        width: parent.width
        visible: previewableImage && !(persistantSettings.compactImages && compact)
        url: previewableImage&&!(compact &&persistantSettings.compactImages) ? link.url : ""
        previewUrl: link.previewUrl
    }

    PostButtonRow {
        id: bottomRow
        linkSaveManager: linkDelegate.linkSaveManager
        linkVoteManager: linkDelegate.linkVoteManager
        link: linkDelegate.link
        anchors {bottom: parent.bottom; left: parent.left; right: parent.right}
    }
}

