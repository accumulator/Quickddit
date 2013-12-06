import QtQuick 1.1
import com.nokia.meego 1.0

ContextMenu {
    id: commentDialog

    property variant comment
    property string linkPermalink

    property bool __isClosing: false

    signal positionToParent

    MenuLayout {
        MenuItem {
            text: "Permalink"
            onClicked: {
                var link = QMLUtils.getRedditFullUrl(linkPermalink + comment.fullname.substring(3));
                globalDialogManager.createOpenLinkDialog(commentPage, link);
            }
        }
        MenuItem {
            enabled: comment.depth > 0
            text: "Parent"
            onClicked: positionToParent();
        }
    }

    Component.onCompleted: open();

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) commentDialog.destroy(250)
    }
}
