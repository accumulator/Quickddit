/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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
    title: "Image"

    property alias imageUrl: imageItem.source
    property alias imgurUrl: imgurManager.imgurUrl

    // to make the image outside of the page not visible during page transitions
    clip: true

    SilicaFlickable {
        id: imageFlickable
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: thumbnailListView.top }
        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        onHeightChanged: if (imageItem.status == Image.Ready) imageItem.fitToScreen()

        PullDownMenu {
            MenuItem {
                text: "Save Image"
                onClicked: QMLUtils.saveImage(imageUrl.toString());
            }
            MenuItem {
                text: "URL"
                onClicked: globalUtils.createOpenLinkDialog(imgurUrl || imageUrl.toString());
            }
        }

        Item {
            id: imageContainer
            width: Math.max(imageItem.width * imageItem.scale, imageFlickable.width)
            height: Math.max(imageItem.height * imageItem.scale, imageFlickable.height)

            AnimatedImage {
                id: imageItem

                property real prevScale: 0
                property real fitScale: 0

                function fitToScreen() {
                    fitScale = Math.min(imageFlickable.width / width, imageFlickable.height / height)
                    imageItem.scale = fitScale
                    prevScale = fitScale
                    pinchArea.minScale = Math.min(fitScale, 1)
                }

                anchors.centerIn: parent
                asynchronous: true
                smooth: !imageFlickable.moving
                cache: false
                fillMode: Image.PreserveAspectFit
                // pause the animation when app is in background
                paused: imageViewPage.status != PageStatus.Active || !Qt.application.active

                onScaleChanged: {
                    if (prevScale == 0)
                        prevScale = scale
                    if ((width * scale) > imageFlickable.width) {
                        var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) * scale / prevScale;
                        imageFlickable.contentX = xoff - imageFlickable.width / 2
                    }
                    if ((height * scale) > imageFlickable.height) {
                        var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) * scale / prevScale;
                        imageFlickable.contentY = yoff - imageFlickable.height / 2
                    }
                    prevScale = scale
                }

                onHeightChanged: {
                    if (status == Image.Ready) {
                        fitToScreen()
                        loadedAnimation.start()
                    }
                }

                NumberAnimation {
                    id: loadedAnimation
                    target: imageItem
                    property: "opacity"
                    duration: 250
                    from: 0; to: 1
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Loader {
            id: busyIndicatorLoader
            anchors.centerIn: parent
            sourceComponent: {
                if (imgurManager.busy)
                    return busyIndicatorComponent;

                switch (imageItem.status) {
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

                    BusyIndicator {
                        id: busyIndicator
                        size: BusyIndicatorSize.Large
                        running: true
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: !imgurManager.busy
                        font.pixelSize: constant.fontSizeSmall
                        text: Math.round(imageItem.progress * 100) + "%"
                    }
                }
            }

            Component { id: failedLoading; Label { text: "Error loading image" } }
        }

        PinchArea {
            id: pinchArea

            property real minScale: 1.0
            property real maxScale: 3.0

            anchors.fill: parent
            enabled: imageItem.status == Image.Ready
            pinch.target: imageItem
            pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
            pinch.maximumScale: maxScale * 1.5 // when over zoomed

            onPinchFinished: {
                imageFlickable.returnToBounds()
                if (imageItem.scale < pinchArea.minScale) {
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if (imageItem.scale > pinchArea.maxScale) {
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }

            NumberAnimation {
                id: bounceBackAnimation
                target: imageItem
                duration: 250
                property: "scale"
                from: imageItem.scale
            }

            // workaround to qt5.2 bug
            // otherwise pincharea is ignored
            // Copied from: https://github.com/veskuh/Tweetian/commit/ad70015c7c50537db4bcd66f3077e2483f735113
            // And: http://talk.maemo.org/showthread.php?p=1466386#post1466386
            Rectangle {
                opacity: 0.0
                anchors.fill: parent
            }

            MouseArea {
                z: parent.z + 1
                anchors.fill: parent
                enabled: imageItem.status == Image.Ready

                onClicked: {
                    if (!dclickTimer.running) {
                        dclickTimer.start();
                        return;
                    }

                    dclickTimer.stop();

                    if (imageItem.scale > imageItem.fitScale) {
                        imageFlickable.returnToBounds()
                        bounceBackAnimation.to = imageItem.fitScale
                        bounceBackAnimation.start()
                    } else {
                        imageFlickable.returnToBounds()
                        bounceBackAnimation.to = imageItem.fitScale * 2.0
                        bounceBackAnimation.start()
                    }
                }

                Timer {
                    id: dclickTimer
                    interval: 300
                }

            }
        }

        ScrollDecorator {}
    }

    ListView {
        id: thumbnailListView
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: visible ? 150 : 0
        visible: count > 0
        model: imgurManager.thumbnailUrls
        orientation: Qt.Horizontal
        delegate: Item {
            id: thumbnailDelegate
            height: ListView.view.height
            width: height

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
                border.color: index == imgurManager.selectedIndex ? "steelblue" : "black"
                border.width: 4
            }

            MouseArea {
                anchors.fill: parent
                onClicked: imgurManager.selectedIndex = index;
            }
        }

        onModelChanged: positionViewAtIndex(imgurManager.selectedIndex, ListView.Center);
    }

    ImgurManager {
        id: imgurManager
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    Binding {
        target: imageItem
        property: "source"
        value: imgurManager.imageUrl
        when: imageViewPage.imgurUrl
    }

    Connections {
        target: QMLUtils
        onSaveImageSucceeded: infoBanner.alert("Image saved to gallery");
        onSaveImageFailed: infoBanner.alert("Image save failed!");
    }
}
