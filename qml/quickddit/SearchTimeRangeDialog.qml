import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {
    id: searchTimeRangeDialog

    property bool __isClosing: false

    titleText: "Time Range"
    model: ListModel {
        ListElement { text: "All time" }
        ListElement { text: "This hour" }
        ListElement { text: "Today" }
        ListElement { text: "This week" }
        ListElement { text: "This month" }
        ListElement { text: "This year" }
    }

    Component.onCompleted: searchTimeRangeDialog.open()
    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) searchTimeRangeDialog.destroy(250)
    }
}
