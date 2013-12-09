import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {
    id: searchSortDialog

    property bool __isClosing: false

    titleText: "Sort By"
    model: ListModel {
        ListElement { text: "Relevance" }
        ListElement { text: "New" }
        ListElement { text: "Hot" }
        ListElement { text: "Top" }
        ListElement { text: "Comments" }
    }

    Component.onCompleted: searchSortDialog.open()
    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) searchSortDialog.destroy(250)
    }
}
