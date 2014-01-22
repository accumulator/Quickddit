import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

ContextMenu {
    id: messageMenu

    property variant message
    property MessageManager messageManager
    property bool enableMarkRead: true

    MenuLayout {
        MenuItem {
            enabled: enableMarkRead && !messageManager.busy
            text: message.isUnread ? "Mark As Read" : "Mark As Unread"
            onClicked: message.isUnread ? messageManager.markRead(message.fullname)
                                        : messageManager.markUnread(message.fullname);
        }
    }
}
