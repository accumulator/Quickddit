import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

AbstractPage {
    id: subredditsBrowsePage
    title: subredditModel.section == SubredditModel.SearchSection
           ? "Subreddits Search: " + searchQuery
           : subredditsSectionModel[subredditModel.section]
    busy: subredditModel.busy

    property alias searchQuery: subredditModel.query
    property bool isSearch: searchQuery

    readonly property variant subredditsSectionModel: ["Popular Subreddits", "New Subreddits",
        "My Subreddits - Subscriber", "My Subreddits - Approved Submitter", "My Subreddits - Moderator"]

    function refresh() {
        subredditModel.refresh(false);
    }

    SilicaListView {
        id: subredditsListView
        anchors.fill: parent
        model: subredditModel

        PullDownMenu {
            MenuItem {
                text: "Section"
                onClicked: {
                    globalUtils.createSelectionDialog("Section", subredditsSectionModel, subredditModel.section,
                    function(selectedIndex) {
                        subredditModel.section = selectedIndex;
                        subredditModel.refresh(false);
                    })
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: subredditModel.refresh(false);
            }
        }

        header: PageHeader { title: subredditsBrowsePage.title }

        delegate: SubredditDelegate {
            onClicked: {
                var mainPage = pageStack.find(function(page) { return page.objectName == "mainPage"; });
                mainPage.refresh(model.displayName);
                pageStack.pop(mainPage);
            }
        }

        PushUpMenu {
            MenuItem {
                text: "Load more"
                enabled: !subredditModel.busy
                onClicked: subredditModel.refresh(true);
            }
        }

        ViewPlaceholder { enabled: subredditsListView.count == 0 && !subredditModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        section: isSearch ? SubredditModel.SearchSection : SubredditModel.PopularSection
        onError: infoBanner.alert(errorString);
    }
}
