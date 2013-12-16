import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: searchPage

    property alias searchQuery: searchModel.searchQuery

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
        model: searchModel
        delegate: LinkDelegate {
            showSubreddit: true
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
        }
        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !searchModel.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: searchModel.refresh(true);
            }
        }

        EmptyContentLabel { visible: searchListView.count == 0 && !searchModel.busy }
    }

    ScrollDecorator { flickableItem: searchListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "Search Result: " + searchModel.searchQuery
        busy: searchModel.busy
        onClicked: searchListView.positionViewAtBeginning()
    }

    LinkModel {
        id: searchModel
        section: LinkModel.SearchSection
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        type: VoteManager.Link
        model: searchModel
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __searchSortDialogComponent: null
        property Component __searchTimeRangeDialogComponent: null

        function createSearchSortDialog() {
            if (!__searchSortDialogComponent)
                __searchSortDialogComponent = Qt.createComponent("SearchSortDialog.qml");
            var p = { selectedIndex: searchModel.searchSort }
            var dialog = __searchSortDialogComponent.createObject(searchPage, p);
            if (!dialog) {
                console.log("Error creating dialog:", __searchSortDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                searchModel.searchSort = dialog.selectedIndex;
                searchModel.refresh(false);
            })
        }

        function createSearchTimeRangeDialog() {
            if (!__searchTimeRangeDialogComponent)
                __searchTimeRangeDialogComponent = Qt.createComponent("SearchTimeRangeDialog.qml");
            var p = { selectedIndex: searchModel.searchTimeRange }
            var dialog = __searchTimeRangeDialogComponent.createObject(searchPage, p);
            if (!dialog) {
                console.log("Error creating dialog:", __searchTimeRangeDialogComponent.errorString);
                return;
            }
            dialog.accepted.connect(function() {
                searchModel.searchTimeRange = dialog.selectedIndex;
                searchModel.refresh(false);
            })
        }
    }

    Component.onCompleted: searchModel.refresh(false);
}
