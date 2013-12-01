import QtQuick 1.1
import com.nokia.meego 1.0

SelectionDialog {
    id: subredditsSectionDialog

    property bool __isClosing: false

    titleText: "Section"
    selectedIndex: subredditManager.section
    model: ListModel {
        ListElement { text: "Popular Subreddits" }
        ListElement { text: "New Subreddits" }
        ListElement { text: "My Subreddits - Subscriber" }
        ListElement { text: "My Subreddits - Approved Submitter" }
        ListElement { text: "My Subreddits - Moderator" }
    }

    Component.onCompleted: open();

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) subredditsSectionDialog.destroy(250)
    }
}
