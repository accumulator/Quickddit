import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

ContextMenu {
    id: messageMenu

    property variant message
    property MessageManager messageManager
    property bool enableMarkRead: true

    MenuItem {
        enabled: enableMarkRead && !messageManager.busy
        text: message.isUnread ? qsTr("Mark As Read") : qsTr("Mark As Unread")
        onClicked: message.isUnread ? messageManager.markRead(message.fullname)
                                    : messageManager.markUnread(message.fullname);
    }
}
