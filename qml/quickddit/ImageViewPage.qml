import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: imageViewPage

    property alias imageUrl: imageItem.source

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
    }

    // to make the image outside of the page not visible during page transitions
    clip: true

    states: State {
        name: "hidden"
        AnchorChanges { target: zoomSlider; anchors.right: undefined; anchors.left: imageViewPage.right }
    }
    transitions: Transition { AnchorAnimation { duration: 250; easing.type: Easing.InOutQuad } }

    Flickable {
        id: flickable
        anchors.fill: parent
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

                asynchronous: true
                anchors.centerIn: parent
                smooth: !flickable.moving
                cache: false
                fillMode: Image.PreserveAspectFit
                // pause the animation when app is in background
                paused: imageViewPage.status != PageStatus.Active || !platformWindow.active

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

        MouseArea {
            anchors.fill: parent
            onClicked: imageViewPage.state = (imageViewPage.state ? "" : "hidden")
        }
    }

    Loader {
        anchors.centerIn: parent
        sourceComponent: {
            switch (imageItem.status) {
            case Image.Loading: return loadingIndicator
            case Image.Error: return failedLoading
            default: return undefined
            }
        }

        Component {
            id: loadingIndicator

            BusyIndicator {
                id: busyIndicator
                running: true
                platformStyle: BusyIndicatorStyle { size: "large" }

                Text {
                    anchors.centerIn: parent
                    color: constant.colorLight
                    font.pixelSize: constant.fontSizeSmall
                    text: Math.round(imageItem.progress * 100) + "%"
                }
            }
        }

        Component { id: failedLoading; Label { text: "Error loading image" } }
    }

    ScrollDecorator { flickableItem: flickable }

    Slider {
        id: zoomSlider
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: constant.paddingMedium }
        enabled: imageItem.status == Image.Ready
        height: parent.height * 0.6
        minimumValue: pinchArea.minScale
        maximumValue: pinchArea.maxScale
        stepSize: (maximumValue - minimumValue) / 20
        orientation: Qt.Vertical

        Behavior on opacity { NumberAnimation { duration: 150 } }

        // When not pressed, bind slider value to image scale
        Binding {
            target: zoomSlider
            property: "value"
            value: imageItem.scale
            when: !zoomSlider.presseds
        }

        // When pressed, bind image scale to slider value
        Binding {
            target: imageItem
            property: "scale"
            value: zoomSlider.value
            when: zoomSlider.pressed
        }
    }
}
