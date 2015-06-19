import QtQuick 1.1

// draws a text in a bubble
Text {
    // defaults, usually overridden
    font.pixelSize: constant.fontSizeDefault
    color: constant.colorLight

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.leftMargin: -5
        anchors.rightMargin: -5
        color: constant.colorMid
        opacity: 0.2
        radius: 6
    }
}
