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

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

Page {
    id: imageViewPage

    property alias imageUrl: imageItem.source
    property alias imgurUrl: imgurManager.imgurUrl

    tools: ToolBarLayout {

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-undo" + (enabled ? "" : "-dimmed")
            enabled: imageItem.scale != pinchArea.minScale
            onClicked: {
                flickable.returnToBounds()
                bounceBackAnimation.to = pinchArea.minScale
                bounceBackAnimation.start()
            }
        }
        ToolIcon {
            iconSource: "image://theme/icon-l-browser-main-view"
            onClicked: globalUtils.createOpenLinkDialog(imgurUrl || imageUrl.toString());
        }
    }

    // to make the image outside of the page not visible during page transitions
    clip: true

    Flickable {
        id: flickable
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: thumbnailListView.top }
        contentWidth: imageContainer.width; contentHeight: imageContainer.height
        onHeightChanged: if (imageItem.status == Image.Ready) imageItem.fitToScreen()

        Item {
            id: imageContainer
            width: Math.max(imageItem.width * imageItem.scale, flickable.width)
            height: Math.max(imageItem.height * imageItem.scale, flickable.height)

            AnimatedImage {
                id: imageItem

                property real prevScale

                function fitToScreen() {
                    scale = Math.min(flickable.width / width, flickable.height / height, 1)
                    pinchArea.minScale = scale
                    prevScale = scale
                }

                anchors.centerIn: parent
                asynchronous: true
                smooth: !flickable.moving
                cache: false
                fillMode: Image.PreserveAspectFit
                // pause the animation when app is in background
                paused: imageViewPage.status != PageStatus.Active || !Qt.application.active

                onScaleChanged: {
                    if ((width * scale) > flickable.width) {
                        var xoff = (flickable.width / 2 + flickable.contentX) * scale / prevScale;
                        flickable.contentX = xoff - flickable.width / 2
                    }
                    if ((height * scale) > flickable.height) {
                        var yoff = (flickable.height / 2 + flickable.contentY) * scale / prevScale;
                        flickable.contentY = yoff - flickable.height / 2
                    }
                    prevScale = scale
                }

                onStatusChanged: {
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

                BusyIndicator {
                    running: true
                    platformStyle: BusyIndicatorStyle { size: "large" }

                    Text {
                        anchors.centerIn: parent
                        color: constant.colorLight
                        font.pixelSize: constant.fontSizeSmall
                        visible: !imgurManager.busy
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
                flickable.returnToBounds()
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
        }
    }

    ScrollDecorator { flickableItem: flickable }

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
                anchors { fill: parent; margins: selectedIndicator.border.width / 2 }
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
}
