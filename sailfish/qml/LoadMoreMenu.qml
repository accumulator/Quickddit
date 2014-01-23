import QtQuick 2.0
import Sailfish.Silica 1.0

PushUpMenu {
    id: loadMoreMenu

    property alias loadMoreVisible: loadMoreItem.visible
    property alias loadMoreEnabled: loadMoreItem.enabled

    signal clicked

    spacing: constant.paddingMedium
    quickSelect: true

    MenuLabel {
        visible: !loadMoreVisible
        text: "End Of List"
    }

    MenuItem {
        id: loadMoreItem
        text: "Load More"
        onClicked: loadMoreMenu.clicked();
    }
}
