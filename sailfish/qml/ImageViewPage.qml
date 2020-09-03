/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2020  Sander van Grieken

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

AbstractPage {
    id: imageViewPage
    title: qsTr("Image")

    property alias imageUrl: viewer.source
    property alias imgurUrl: imgurManager.imgurUrl
    property alias galleryUrl: galleryManager.galleryUrl
    property QtObject activeManager: imgurManager.imgurUrl ? imgurManager : galleryManager

    // to make the image outside of the page not visible during page transitions
    clip: true

    SilicaFlickable {
        id: imageFlickable
        anchors {
            top: parent.top; left: parent.left;
            right: isPortrait ? parent.right : thumbnailListView.left;
            bottom: isPortrait ? thumbnailListView.top : parent.bottom
        }
        contentWidth: viewer.width; contentHeight: viewer.height

        // When orientation changes, both height and width properties receive changed events
        // in random order. Fire a short timer to wait out the updates, then fit to screen
        onHeightChanged: {
            resizeTimer.start()
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Save Image")
                enabled: imageUrl.toString() !== ""
                onClicked: QMLUtils.saveImage(imageUrl.toString());
            }
            MenuItem {
                text: qsTr("URL")
                onClicked: globalUtils.createOpenLinkDialog(imgurUrl || galleryUrl || imageUrl.toString());
            }
        }

        ImageViewer {
            id: viewer
            flickable: imageFlickable
            // pause the animation when app is in background
            paused: imageViewPage.status !== PageStatus.Active || !Qt.application.active
            onSourceChanged: console.log("source changed: " + source);
        }

        ScrollDecorator {}
    }

    Loader {
        id: busyIndicatorLoader
        anchors.centerIn: parent
        sourceComponent: {
            if (activeManager.busy)
                return busyIndicatorComponent;

            switch (viewer.status) {
            case Image.Loading: return busyIndicatorComponent
            case Image.Error: return failedLoading
            default: return undefined
            }
        }

        Component {
            id: busyIndicatorComponent

            Item {
                width: busyIndicator.width
                height: busyIndicator.height

                anchors.centerIn: parent

                BusyIndicator {
                    id: busyIndicator
                    size: BusyIndicatorSize.Large
                    running: true
                }

                Label {
                    anchors.centerIn: parent
                    visible: !activeManager.busy
                    font.pixelSize: constant.fontSizeSmall
                    text: Math.round(viewer.progress * 100) + "%"
                }
            }
        }

        Component { id: failedLoading; Label { text: qsTr("Error loading image") } }
    }

    ListView {
        id: thumbnailListView
        property int _itemSize: 150

        anchors {
            left: isPortrait ? parent.left : undefined;
            right: parent.right;
            top: isPortrait ? undefined : parent.top;
            bottom: parent.bottom
        }
        height: isPortrait
                ? visible ? _itemSize : 0
                : undefined
        width: isPortrait
               ? undefined
               : visible ? _itemSize : 0
        visible: count > 0
        model: activeManager.thumbnailUrls
        orientation: isPortrait ? Qt.Horizontal : Qt.Vertical
        delegate: Item {
            id: thumbnailDelegate
            height: thumbnailListView._itemSize
            width: thumbnailListView._itemSize

            Image {
                id: thumbnailImage
                anchors.fill: parent
                asynchronous: true
                cache: true
                smooth: !thumbnailDelegate.ListView.view.moving
                fillMode: Image.PreserveAspectCrop
                source: modelData
            }

            Loader {
                anchors.centerIn: parent
                sourceComponent: thumbnailImage.status == Image.Loading ? thumbnailBusy : undefined

                Component { id: thumbnailBusy; BusyIndicator { running: true } }
            }

            Rectangle {
                id: selectedIndicator
                anchors.fill: parent
                color: "transparent"
                border.color: index === activeManager.selectedIndex ? "steelblue" : "black"
                border.width: 4
            }

            MouseArea {
                anchors.fill: parent
                onClicked: activeManager.selectedIndex = index;
            }
        }

        onModelChanged: positionViewAtIndex(activeManager.selectedIndex, ListView.Center)
        onOrientationChanged: latePositioning.start()

        Timer {
            id: latePositioning
            interval: 0; repeat: false
            onTriggered: thumbnailListView.positionViewAtIndex(activeManager.selectedIndex, ListView.Center)
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

    Binding {
        target: viewer
        property: "source"
        value: imgurManager.imageUrl
        when: imageViewPage.imgurUrl
    }

    Binding {
        target: viewer
        property: "source"
        value: galleryManager.imageUrl
        when: imageViewPage.galleryUrl.toString() !== ""
    }

    Connections {
        target: QMLUtils
        onSaveImageSucceeded: infoBanner.alert(qsTr("Image saved to gallery"));
        onSaveImageFailed: infoBanner.warning(qsTr("Image save failed!"));
    }

    Timer {
        id: resizeTimer
        interval: 1
        repeat: false

        onTriggered: viewer._fitToScreen()
    }
}
