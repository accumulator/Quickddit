import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: searchDialog

    acceptDestination: Qt.resolvedUrl("SearchPage.qml")
    acceptDestinationAction: PageStackAction.Replace
    canAccept: searchTextField.text.length > 0

    onAccepted: {
        Qt.inputMethod.commit(); // not sure if this is needed
        acceptDestinationInstance.searchQuery = searchTextField.text;
        acceptDestinationInstance.refresh();
    }

    Column {
        anchors { left: parent.left; right: parent.right }
        height: childrenRect.height

        DialogHeader {
            title: "Search"
            dialog: searchDialog
        }

        TextField {
            id: searchTextField
            anchors { left: parent.left; right: parent.right }
            placeholderText: "Enter search query..."
            EnterKey.enabled: searchDialog.canAccept
            EnterKey.iconSource: "image://theme/icon-m-search"
            EnterKey.onClicked: accept();
        }

        ComboBox {
            id: searchTypeComboBox
            anchors { left: parent.left; right: parent.right }
            label: "Search for"
            menu: ContextMenu {
                MenuItem { text: "Posts" }
                MenuItem { text: "Subreddits" }
            }
            onCurrentIndexChanged: {
                if (currentIndex == 0) {
                    acceptDestinationProperties = {}
                    acceptDestination = Qt.resolvedUrl("SearchPage.qml")
                } else {
                    acceptDestinationProperties = { isSearch: true }
                    acceptDestination = Qt.resolvedUrl("SubredditsBrowsePage.qml")
                }
            }
        }
    }
}
