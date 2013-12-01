import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {
    id: sectionDialog

    property bool __isClosing: false

    titleText: "Section"
    selectedIndex: linkManager.section
    model: ListModel {
        ListElement { text: "Hot" }
        ListElement { text: "New" }
        ListElement { text: "Rising" }
        ListElement { text: "Controversial" }
        ListElement { text: "Top" }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) sectionDialog.destroy(250)
    }
}
