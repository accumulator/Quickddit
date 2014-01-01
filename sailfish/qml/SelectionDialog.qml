import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: selectionDialog

    property alias titleText: header.title
    property alias model: listView.model
    property int selectedIndex: -1

    canAccept: false

    DialogHeader {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
    }

    ListView {
        id: listView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        delegate: ListItem {
            contentHeight: Theme.itemSizeSmall

            Label {
                anchors {
                    verticalCenter: parent.verticalCenter;
                    left: parent.left; right: parent.right; margins: Theme.paddingLarge
                }
                font.pixelSize: Theme.fontSizeMedium
                font.bold: selectionDialog.selectedIndex == index
                color: selectionDialog.selectedIndex == index ? Theme.primaryColor : Theme.highlightColor
                elide: Text.ElideRight
                text: modelData
            }

            onClicked: {
                selectionDialog.selectedIndex = index;
                canAccept = true;
                selectionDialog.accept();
            }
        }
    }
}
