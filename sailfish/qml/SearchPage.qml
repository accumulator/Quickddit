import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

AbstractPage {
    id: searchPage
    title: "Search Result: " + searchModel.searchQuery
    busy: searchModel.busy || linkVoteManager.busy

    property alias searchQuery: searchModel.searchQuery

    readonly property variant sortModel: ["Relevance", "New", "Hot", "Top", "Comments"]
    readonly property variant timeRangeModel: ["All time", "This hour", "Today", "This week",
        "This month", "This year"]

    function refresh() {
        searchModel.refresh(false);
    }

    SilicaListView {
        id: searchListView
        anchors.fill: parent
        model: searchModel

        PullDownMenu {
            MenuItem {
                text: "Time Range"
                onClicked: {
                    globalUtils.createSelectionDialog("Time Range", timeRangeModel, searchModel.searchTimeRange,
                    function(selectedIndex) {
                        searchModel.searchTimeRange = selectedIndex;
                        searchModel.refresh(false);
                    })
                }
            }

            MenuItem {
                text: "Sort"
                onClicked: {
                    globalUtils.createSelectionDialog("Sort", sortModel, searchModel.searchSort,
                    function(selectedIndex) {
                        searchModel.searchSort = selectedIndex;
                        searchModel.refresh(false);
                    })
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: searchModel.refresh(false);
            }
        }

        header: PageHeader { title: searchPage.title }

        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showMenuOnPressAndHold: false
            showSubreddit: true
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: showMenu({link: model, linkVoteManager: linkVoteManager});
        }

        PushUpMenu {
            MenuItem {
                text: "Load more"
                enabled: !searchModel.busy
                onClicked: searchModel.refresh(true);
            }
        }

        ViewPlaceholder { enabled: searchListView.count == 0 && !searchModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
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
}
