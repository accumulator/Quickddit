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
import QtGraphicalEffects 1.0

ItemDelegate {
    id:linkDelegate

    property bool compact: true
    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager
    property bool previewableImage: globalUtils.previewableImage(link.url)
    property bool previewableVideo: globalUtils.previewableVideo(link.url)
    property bool imgur: /^https?:\/\/((i|m|www)\.)?imgur\.com\//.test(link.url)

    width: parent.width
    height: Math.max(titulok.height+pic.height,txt.height+titulok.height,thumb.height)+info.height+bottomRow.height

    onClicked: {
        if(!compact&&!globalUtils.redditLink(link.url))
            globalUtils.openLink(link.url)
    }

    //info
    Label {
        id: info
        padding: 5
        anchors {top: parent.top; left: parent.left; right: parent.right; }
        elide: Text.ElideRight
        text: "<a href='r/"+link.subreddit+"'>"+"r/"+link.subreddit+"</a>"+" ~ <a href='u/"+link.author+"'>"+"u/"+link.author+"</a>"+" ~ "+link.created+" ~ "+link.domain
        onLinkActivated: {
            if(link.charAt(0)=='r')
                pageStack.push(Qt.resolvedUrl("SubredditPage.qml"),{subreddit:link.slice(2)})
            if(link.charAt(0)=='u'){
                pageStack.push(Qt.resolvedUrl("UserPage.qml"),{username:link.slice(2).split(" ")[0]})
            }
        }
    }
    //title
    Label {
        padding: 5
        anchors {top: info.bottom; right: parent.right; left:thumb.visible ? thumb.right : parent.left;}
        id: titulok
        text: link.title
        elide: Text.ElideRight
        maximumLineCount: compact ? 3 : 9999
        font.pointSize: 12
        font.weight: Font.DemiBold
        wrapMode: Text.Wrap
    }
    //text
    Label{
        id:txt
        padding: 5
        anchors.right: parent.right
        anchors.top: titulok.bottom
        anchors.left: thumb.visible ? thumb.right : parent.left
        text:(compact? link.rawText : link.text)
        elide: Text.ElideRight
        maximumLineCount: compact ? 3:9999
        font.pointSize: 10
        wrapMode: Text.WordWrap
        textFormat: Text.StyledText
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
        url: previewableImage&&!(compact &&persistantSettings.compactImages) ? (persistantSettings.fullResolutionImages &&!imgur ? link.url : link.previewUrl) : ""
    }

    PostButtonRow {
        id: bottomRow
        linkSaveManager: linkDelegate.linkSaveManager
        linkVoteManager: linkDelegate.linkVoteManager
        link: linkDelegate.link
        anchors {bottom: parent.bottom; left: parent.left; right: parent.right}
    }
}

