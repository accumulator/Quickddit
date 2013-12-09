import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: searchPage

    property alias searchQuery: searchManager.searchQuery

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: dialogManager.createSearchSortDialog();
        }
        ToolIcon {
            platformIconId: "toolbar-clock"
            onClicked: dialogManager.createSearchTimeRangeDialog();
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
        text: "Search Result: " + searchManager.searchQuery
        busy: searchManager.busy
        onClicked: searchListView.positionViewAtBeginning()
    }

    LinkManager {
        id: searchManager
        section: LinkManager.SearchSection
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __searchSortDialogComponent: null
        property Component __searchTimeRangeDialogComponent: null

        function createSearchSortDialog() {
            if (!__searchSortDialogComponent)
                __searchSortDialogComponent = Qt.createComponent("SearchSortDialog.qml");
            var p = { selectedIndex: searchManager.searchSort }
            var dialog = __searchSortDialogComponent.createObject(searchPage, p);
            if (!dialog) {
                console.log("Error creating dialog:", __searchSortDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                searchManager.searchSort = dialog.selectedIndex;
                searchManager.refresh(false);
            })
        }

        function createSearchTimeRangeDialog() {
            if (!__searchTimeRangeDialogComponent)
                __searchTimeRangeDialogComponent = Qt.createComponent("SearchTimeRangeDialog.qml");
            var p = { selectedIndex: searchManager.searchTimeRange }
            var dialog = __searchTimeRangeDialogComponent.createObject(searchPage, p);
            if (!dialog) {
                console.log("Error creating dialog:", __searchTimeRangeDialogComponent.errorString);
                return;
            }
            dialog.accepted.connect(function() {
                searchManager.searchTimeRange = dialog.selectedIndex;
                searchManager.refresh(false);
            })
        }
    }

    Component.onCompleted: searchManager.refresh(false);
}
