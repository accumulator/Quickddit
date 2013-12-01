import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {
    id: commentSortDialog

    property bool __isClosing: false

    titleText: "Sort comments by"
    selectedIndex: commentManager.sort
    model: ListModel {
        ListElement { text: "Best" }
        ListElement { text: "Top" }
        ListElement { text: "New" }
        ListElement { text: "Hot" }
        ListElement { text: "Controversial" }
        ListElement { text: "Old" }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) commentSortDialog.destroy(250)
    }
}
