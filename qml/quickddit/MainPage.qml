import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: mainPage

    function refreshToFrontPage() {
        linkModel.refresh(false);
    }

    function setSubreddit(subreddit) {
        linkModel.subreddit = subreddit;
        linkModel.refresh(false);
    }

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back-dimmed"
            enabled: false
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: dialogManager.createSubredditDialog();
        }
        ToolIcon {
            platformIconId: enabled ? "toolbar-refresh" : "toolbar-refresh-dimmed"
            enabled: !linkModel.busy
            onClicked: linkModel.refresh(false)
        }
        ToolIcon {
            platformIconId: "toolbar-search"
            onClicked: dialogManager.createSearchDialog()
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open()
        }
    }

    Menu {
        id: menu

        MenuLayout {
            MenuItem {
                text: "Section"
                onClicked: dialogManager.createSectionDialog();
            }
            MenuItem {
                text: "About /r/" + linkModel.subreddit
                visible: linkModel.subreddit != "" && linkModel.subreddit.toLowerCase() != "all"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutSubredditPage.qml"), {subreddit: linkModel.subreddit});
                }
            }
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("AppSettingsPage.qml"))
            }
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }

    ListView {
        id: linkListView
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: linkModel
        delegate: LinkDelegate {
            showSubreddit: linkModel.subreddit == ""
                           || linkModel.subreddit.toLowerCase() == "all"
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: dialogManager.createLinkDialog(model);
        }
        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !linkModel.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: linkModel.refresh(true);
            }
        }

        EmptyContentLabel { visible: linkListView.count == 0 && !linkModel.busy }
    }

    ScrollDecorator { flickableItem: linkListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: linkModel.title
        busy: linkModel.busy || linkVoteManager.busy
        onClicked: linkListView.positionViewAtBeginning()
    }

    LinkModel {
        id: linkModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        type: VoteManager.Link
        model: linkModel
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __subredditDialogComponent: null
        property Component __searchDialogComponent: null
        property Component __sectionDialogComponent: null
        property Component __linkDialogComponent: null

        property Component __subredditDialogModelComponent: Component {
            SubredditModel {
                manager: quickdditManager
                section: SubredditModel.UserAsSubscriberSection
                onError: infoBanner.alert(errorString);
            }
        }
        property QtObject __subredditDialogModel

        function createSubredditDialog() {
            if (!__subredditDialogComponent)
                __subredditDialogComponent = Qt.createComponent("SubredditDialog.qml");
            var p = {};
            if (quickdditManager.isSignedIn) {
                if (!__subredditDialogModel)
                    __subredditDialogModel = __subredditDialogModelComponent.createObject(mainPage);
                p.subredditModel = __subredditDialogModel;
            }
            var dialog = __subredditDialogComponent.createObject(mainPage, p);
            if (!dialog) {
                console.log("Error creating object: " + __subredditDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                if (dialog.browseSubreddits) {
                    pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"));
                } else {
                    linkModel.subreddit = dialog.text;
                    linkModel.refresh(false);
                }
            })
        }

        function createSearchDialog() {
            if (!__searchDialogComponent)
                __searchDialogComponent = Qt.createComponent("SearchDialog.qml");
            var dialog = __searchDialogComponent.createObject(mainPage);
            if (!dialog) {
                console.log("Error creating object: " + __searchDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                if (dialog.text) {
                    var p = { searchQuery: dialog.text };
                    if (dialog.type == 0)
                        pageStack.push(Qt.resolvedUrl("SearchPage.qml"), p);
                    else
                        pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"), p);
                } else {
                    infoBanner.alert("Please enter some text to search!");
                }
            })
        }

        function createSectionDialog() {
            if (!__sectionDialogComponent)
                __sectionDialogComponent = Qt.createComponent("SectionDialog.qml");
            var p = { selectedIndex: linkModel.section }
            var dialog = __sectionDialogComponent.createObject(mainPage, p);
            if (!dialog) {
                console.log("Error creating object: " + __sectionDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                linkModel.section =  dialog.selectedIndex;
                linkModel.refresh(false);
            })
        }

        function createLinkDialog(link) {
            if (!__linkDialogComponent)
                __linkDialogComponent = Qt.createComponent("LinkDialog.qml");
            var p = { link: link, linkVoteManager: linkVoteManager }
            var dialog = __linkDialogComponent.createObject(mainPage, p);
            if (!dialog) {
                console.log("Error create dialog: " + __linkDialogComponent.errorString())
            }
        }
    }
}
