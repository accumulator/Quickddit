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

ItemDelegate {
    id:linkDelegate

    property bool compact: true
    property variant model
    property bool markSaved: true
    property bool previewableImage: globalUtils.previewableImage(model.url)
    property bool previewableVideo: globalUtils.previewableVideo(model.url)
    width: parent.width
    height: Math.max(txt.height+titulok.height,thumb.height)+info.height

    //info
    Label {
        id: info
        padding: 5
        anchors {top: parent.top; left: parent.left; right: parent.right; }
        elide: Text.ElideRight
        text: "<a href='r/"+model.subreddit+"'>"+"r/"+model.subreddit+"</a>"+" ~ <a href='u/"+model.author+"'>"+"u/"+model.author+"</a>"+" ~ "+model.created+" ~ "+model.domain
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
        text: model.title
        elide: Text.ElideRight
        maximumLineCount: 3
        font.pointSize: 12
        font.weight: Font.DemiBold
        wrapMode: Text.Wrap
    }

    //text
    Label{
        padding: 5
        anchors.right: parent.right
        anchors.top: titulok.bottom
        anchors.left: thumb.visible ? thumb.right : parent.left
        id:txt
        text:model.text
        elide: Text.ElideRight
        maximumLineCount: 3
        font.pointSize: 10
        wrapMode: Text.WordWrap
    }

    //preview
    Thumbnail {
        id:thumb
        anchors {left: parent.left; top:info.bottom; leftMargin: 5 }
        video: previewableVideo
        image: previewableImage
        urlPost: !globalUtils.redditLink(model.url)&&!video&&!image
        link: model
        visible: urlPost || image || video
    }
}
