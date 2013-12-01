import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: searchDialog
    acceptButtonText: "Search"
    rejectButtonText: "Cancel"

    property alias text: searchTextField.text
    property int type: 0

    property bool __isClosing: false

    content: Column {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
        height: childrenRect.height
        spacing: constant.paddingLarge

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: "Enter text:"
        }

        TextField {
            id: searchTextField
            anchors { left: parent.left; right: parent.right }
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: "Search for:"
        }

        ButtonRow {
            id: typeButtonRow
            anchors { left: parent.left; right: parent.right }
            onCheckedButtonChanged: {
                if (checkedButton == searchButton) searchDialog.type = 0;
                else searchDialog.type = 1;
            }

            Button {
                id: searchButton
                text: "Posts"
            }

            Button {
                id: subredditButton
                text: "Subreddits"
            }
        }
    }

    Component.onCompleted: searchDialog.open()
    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) searchDialog.destroy(250)
    }
}
