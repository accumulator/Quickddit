import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: subredditsBrowsePage

    property string searchQuery

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: dialogManager.createSubredditsSectionDialog();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: subredditManager.refresh(false);

        }
    }

    ListView {
        id: subredditsListView
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: subredditManager.model
        delegate: SubredditDelegate {}
        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !subredditManager.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: subredditManager.refresh(true);
            }
        }

        EmptyContentLabel { visible: subredditsListView.count == 0 && !subredditManager.busy }
    }

    ScrollDecorator { flickableItem: subredditsListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: {
            switch (subredditManager.section) {
            case SubredditManager.PopularSection: return "Popular Subreddits";
            case SubredditManager.NewSection: return "New Subreddits";
            case SubredditManager.UserAsSubscriberSection: return "My Subreddits - Subscriber";
            case SubredditManager.UserAsContributorSection: return "My Subreddits - Approved Submitter";
            case SubredditManager.UserAsModeratorSection: return "My Subreddits - Moderator";
            case SubredditManager.SearchSection: return "Search Subreddits: " + subredditManager.query;
            }
        }
        busy: subredditManager.busy
        onClicked: subredditsListView.positionViewAtBeginning();
    }

    SubredditManager {
        id: subredditManager
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __subredditsSectionDialogComponent: null

        function createSubredditsSectionDialog() {
            if (!__subredditsSectionDialogComponent)
                __subredditsSectionDialogComponent = Qt.createComponent("SubredditsSectionDialog.qml");
            var dialog = __subredditsSectionDialogComponent.createObject(subredditsBrowsePage);
            if (!dialog) {
                console.log("Error creating dialog:" + __subredditsSectionDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                subredditManager.section = dialog.selectedIndex;
                subredditManager.refresh(false);
            })
        }
    }

    Component.onCompleted: {
        if (searchQuery) {
            subredditManager.section = SubredditManager.SearchSection;
            subredditManager.query = searchQuery;
        }
        subredditManager.refresh(false);
    }
}
