import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

AbstractPage {
    id: searchPage

    property alias searchQuery: searchModel.searchQuery

    /*readonly*/ property variant sortModel: ["Relevance", "New", "Hot", "Top", "Comments"]
    /*readonly*/ property variant timeRangeModel: ["All time", "This hour", "Today", "This week",
        "This month", "This year"]

    title: "Search Result: " + searchModel.searchQuery
    busy: searchModel.busy || linkVoteManager.busy
    onHeaderClicked: searchListView.positionViewAtBeginning();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: {
                globalUtils.createSelectionDialog("Sort", sortModel, searchModel.searchSort,
                function(selectedIndex) {
                    searchModel.searchSort = selectedIndex;
                    searchModel.refresh(false);
                })
            }
        }
        ToolIcon {
            platformIconId: "toolbar-clock"
            onClicked: {
                globalUtils.createSelectionDialog("Time Range", timeRangeModel, searchModel.searchTimeRange,
                function(selectedIndex) {
                    searchModel.searchTimeRange = selectedIndex;
                    searchModel.refresh(false);
                })
            }
        }
    }

    ListView {
        id: searchListView
        anchors.fill: parent
        model: searchModel
        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showSubreddit: true
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: showMenu({link: model, linkVoteManager: linkVoteManager});
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

        ViewPlaceholder { enabled: searchListView.count == 0 && !searchModel.busy }
    }

    ScrollDecorator { flickableItem: searchListView }

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
}
