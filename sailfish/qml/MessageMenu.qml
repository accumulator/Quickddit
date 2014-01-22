import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

ContextMenu {
    id: messageMenu

    property variant message
    property MessageManager messageManager

    MenuItem {
        enabled: !messageManager.busy
        text: message.isUnread ? "Mark As Read" : "Mark As Unread"
        onClicked: message.isUnread ? messageManager.markRead(message.fullname)
                                    : messageManager.markUnread(message.fullname);
    }
}
