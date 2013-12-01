import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: searchPage

    property alias query: searchManager.query

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    ListView {
        id: searchListView
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: searchManager.model
        delegate: LinkDelegate { showSubreddit: true }
        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !searchManager.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: searchManager.refresh(true);
            }
        }

        EmptyContentLabel { visible: searchListView.count == 0 && !searchManager.busy }
    }

    ScrollDecorator { flickableItem: searchListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "Search Result: " + searchManager.query
        busy: searchManager.busy
        onClicked: searchManager.positionViewAtBeginning()
    }

    SearchManager {
        id: searchManager
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    Component.onCompleted: searchManager.refresh(false);
}
