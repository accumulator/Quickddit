import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: textAreaDialog

    property alias text: textArea.text
    property alias titleText: dialogHeader.title

    canAccept: text.length > 0

    onAccepted: Qt.inputMethod.commit(); // not sure if this is needed

    DialogHeader { id: dialogHeader }

    Flickable {
        id: flickable
        anchors { top: dialogHeader.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
        contentHeight: textArea.height
        clip: true

        TextArea {
            id: textArea
            anchors { left: parent.left; right: parent.right }
            height: Math.max(implicitHeight, Theme.itemSizeLarge * 3)
            placeholderText: "Tap here to type..."
        }
    }
}
