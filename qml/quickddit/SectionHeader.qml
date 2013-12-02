import QtQuick 1.1

Item {
    id: sectionHeader
    anchors { left: parent.left; right: parent.right }
    height: titleText.height

    property string title

    Rectangle {
        id: line
        anchors {
            left: parent.left
            right: titleText.left; rightMargin: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        height: 1
        color: constant.colorMid
    }

    Text {
        id: titleText
        anchors { right: parent.right; rightMargin: constant.paddingMedium }
        font.pixelSize: constant.fontSizeSmall
        font.bold: true
        color: constant.colorLight
        text: sectionHeader.title
    }
}
