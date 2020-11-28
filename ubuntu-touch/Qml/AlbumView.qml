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
import quickddit.Core 1.0

Item {
    id: albumView
    property string url
    property string  previewUrl
    property string imageUrl
    property alias imgurUrl: imgurManager.imgurUrl
    property alias galleryUrl: galleryManager.galleryUrl
    property QtObject activeManager: imgurUrl ? imgurManager : galleryManager
    signal download

    height: persistantSettings.compactImages && compact ? 0 : listView.height

    ListView {
        id:listView
        width: parent.width
        height: listView.currentItem ? listView.currentItem.height : 0
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        model: activeManager.imageUrls.length ? activeManager.imageUrls.length : imageUrl ? 1 : 0
        highlightRangeMode: ItemView.StrictlyEnforceRange

        delegate: ZoomableImage {
            id:zimg
            ratio: status===Image.Loading? link.previewHeight? link.previewHeight/link.previewWidth : 1 : sourceSize.height / sourceSize.width
            width: albumView.width
            source: activeManager.imageUrls.length ?
                        !persistantSettings.fullResolutionImages && activeManager.previewUrls ?
                            activeManager.previewUrls[index] : activeManager.imageUrls[index] : !persistantSettings.fullResolutionImages &&previewUrl ?
                                previewUrl : imageUrl
        }

        onCurrentIndexChanged: {
            if (activeManager.imageUrls.length)
                imageUrl = activeManager.imageUrls[currentIndex]
        }

        PageIndicator {
            anchors {bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 20}
            count: parent.count
            currentIndex: parent.currentIndex
            visible: count>1
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                linkDelegate.clicked()
            }
        }
    }

    onUrlChanged: {
        if(!previewableImage)
            return
        else if (/^https?:\/\/\S+\.(jpe?g|png|gif)/i.test(url)) {
            imageUrl = url;
        }
        if (/^https?:\/\/((i|m|www)\.)?imgur\.com/.test(url)) {
            imgurUrl = url;
        }
        else if (/^https?:\/\/i.reddituploads.com\//.test(url))
            imageUrl = url;
        else if (/^(https?:\/\/(\w+\.)?reddit.com)?\/gallery\//.test(url)) {
            galleryUrl = url;
        }
    }

    ImgurManager {
        id: imgurManager
        manager: quickdditManager

        onError: {
            infoBanner.warning(errorString);
            console.log(errorString);
        }
    }

    GalleryManager {
        id: galleryManager
        manager: quickdditManager

        onError: {
            infoBanner.warning(errorString);
            console.log(errorString);
        }
    }
}
