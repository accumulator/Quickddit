/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

Item {
    id: imageViewer

    property QtObject image: imageLoader.item
    property int status
    property real progress: 0
    property url source
    property bool paused: false

    property real prevScale: 0
    property real fitScale: 0

    property Flickable flickable

    width: Math.max(image.width * image.scale, flickable.width)
    height: Math.max(image.height * image.scale, flickable.height)

    function _onScaleChanged() {
        if (prevScale === 0)
            prevScale = image.scale
        if ((image.width * image.scale) > flickable.width) {
            var xoff = (flickable.width / 2 + flickable.contentX) * image.scale / prevScale;
            flickable.contentX = xoff - flickable.width / 2
        }
        if ((image.height * image.scale) > flickable.height) {
            var yoff = (flickable.height / 2 + flickable.contentY) * image.scale / prevScale;
            flickable.contentY = yoff - flickable.height / 2
        }
        prevScale = image.scale
    }

    function _fitToScreen() {
        fitScale = Math.min(flickable.width / image.width, flickable.height / image.height) * 0.999 // rounding errors
        image.scale = fitScale
        prevScale = fitScale
        pinchArea.minScale = Math.min(fitScale, 1)
    }

    Loader {
        id: imageLoader

        property bool safe: false

        anchors.centerIn: parent
        sourceComponent: safe ? safeImageComp : imageComp
    }

    Component {
        id: imageComp

        AnimatedImage {
            id: imageItem

            paused: imageViewer.paused
            source: imageViewer.source

            anchors.centerIn: parent
            asynchronous: true
            smooth: !flickable.moving
            cache: true
            fillMode: Image.PreserveAspectFit

            onScaleChanged: {
                _onScaleChanged()
            }

            onHeightChanged: {
                if (status == Image.Ready) {
                    _fitToScreen()
                    loadedAnimation.start()
                }
                if (height > 4096)
                    parent.safe = true
            }

            onWidthChanged: {
                if (width > 4096)
                    parent.safe = true
            }

            NumberAnimation {
                id: loadedAnimation
                target: imageItem
                property: "opacity"
                duration: 250
                from: 0; to: 1
                easing.type: Easing.InOutQuad
            }

            Binding {
                target: imageViewer
                property: "progress"
                value: imageItem.progress
            }
            Binding {
                target: imageViewer
                property: "status"
                value: imageItem.status
            }

            DisplayBlanking {
                preventBlanking: imageItem.playing
            }

            Component.onCompleted: console.log("Normal Image viewer used")
        }
    }

    Component {
        id: safeImageComp

        Image {
            id: imageItem

            source: imageViewer.source

            // workaround CustomContext::HybrisTexture::bind:313 - Error after glEGLImageTargetTexture2DOES 501
            // animatedimage cannot restrict the source size, which can lead to the above error
            sourceSize.width: 2048
            sourceSize.height: 2048

            anchors.centerIn: parent
            asynchronous: true
            smooth: !flickable.moving
            cache: true
            fillMode: Image.PreserveAspectFit

            onScaleChanged: {
                _onScaleChanged(imageItem)
            }

            onHeightChanged: {
                if (status == Image.Ready) {
                    _fitToScreen()
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

            Binding {
                target: imageViewer
                property: "progress"
                value: imageItem.progress
            }
            Binding {
                target: imageViewer
                property: "status"
                value: imageItem.status
            }

            Component.onCompleted: console.log("Safe Image viewer used")
        }
    }

    PinchArea {
        id: pinchArea

        property real minScale: 1.0
        property real maxScale: 3.0

        anchors.fill: parent
        enabled: imageViewer.status == Image.Ready
        pinch.target: imageViewer.image
        pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
        pinch.maximumScale: maxScale * 1.5 // when over zoomed

        onPinchFinished: {
            flickable.returnToBounds()
            if (imageViewer.image.scale < pinchArea.minScale) {
                bounceBackAnimation.to = pinchArea.minScale
                bounceBackAnimation.start()
            }
            else if (imageViewer.image.scale > pinchArea.maxScale) {
                bounceBackAnimation.to = pinchArea.maxScale
                bounceBackAnimation.start()
            }
        }

        NumberAnimation {
            id: bounceBackAnimation
            target: imageViewer.image
            duration: 250
            property: "scale"
            from: imageViewer.image.scale
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
            enabled: imageViewer.status == Image.Ready

            onClicked: {
                if (!dclickTimer.running) {
                    dclickTimer.start();
                    return;
                }

                dclickTimer.stop();

                // allow 1% above fitscale to handle rounding errors
                if (imageViewer.image.scale > (imageViewer.fitScale * 1.01)) {
                    flickable.returnToBounds()
                    bounceBackAnimation.to = imageViewer.fitScale
                    bounceBackAnimation.start()
                } else {
                    flickable.returnToBounds()
                    bounceBackAnimation.to = imageViewer.fitScale * 2.5
                    bounceBackAnimation.start()
                }
            }

            Timer {
                id: dclickTimer
                interval: 300
            }

        }
    }

}
