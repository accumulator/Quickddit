import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

PageHeader {
    IconButton {
        id: button
        anchors.verticalCenter: extraContent.verticalCenter
        anchors.left: extraContent.left
        anchors.leftMargin: constant.paddingMedium

        icon.source: "image://theme/icon-m-mail"
        visible: inboxManager.hasUnseenUnread
        highlighted: false

        onClicked: {
            if (pageStack.currentPage.objectName === "messagePage") {
                pageStack.currentPage.refresh();
            } else {
                pageStack.push(Qt.resolvedUrl("MessagePage.qml"));
            }
        }
    }

}

