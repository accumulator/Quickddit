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
            onClicked: subredditModel.refresh(false);
        }
    }

    ListView {
        id: subredditsListView
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: subredditModel
        delegate: SubredditDelegate {}
        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !subredditModel.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: subredditModel.refresh(true);
            }
        }

        EmptyContentLabel { visible: subredditsListView.count == 0 && !subredditModel.busy }
    }

    ScrollDecorator { flickableItem: subredditsListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: {
            switch (subredditModel.section) {
            case SubredditModel.PopularSection: return "Popular Subreddits";
            case SubredditModel.NewSection: return "New Subreddits";
            case SubredditModel.UserAsSubscriberSection: return "My Subreddits - Subscriber";
            case SubredditModel.UserAsContributorSection: return "My Subreddits - Approved Submitter";
            case SubredditModel.UserAsModeratorSection: return "My Subreddits - Moderator";
            case SubredditModel.SearchSection: return "Search Subreddits: " + subredditModel.query;
            }
        }
        busy: subredditModel.busy
        onClicked: subredditsListView.positionViewAtBeginning();
    }

    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __subredditsSectionDialogComponent: null

        function createSubredditsSectionDialog() {
            if (!__subredditsSectionDialogComponent)
                __subredditsSectionDialogComponent = Qt.createComponent("SubredditsSectionDialog.qml");
            var p = { selectedIndex: subredditModel.section }
            var dialog = __subredditsSectionDialogComponent.createObject(subredditsBrowsePage, p);
            if (!dialog) {
                console.log("Error creating dialog:" + __subredditsSectionDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                subredditModel.section = dialog.selectedIndex;
                subredditModel.refresh(false);
            })
        }
    }

    Component.onCompleted: {
        if (searchQuery) {
            subredditModel.section = SubredditModel.SearchSection;
            subredditModel.query = searchQuery;
        }
        subredditModel.refresh(false);
    }
}
