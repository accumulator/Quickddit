import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: mainPage

    function refreshToFrontPage() {
        linkManager.refresh(false);
    }

    function setSubreddit(subreddit) {
        linkManager.subreddit = subreddit;
        linkManager.refresh(false);
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
            enabled: !linkManager.busy
            onClicked: linkManager.refresh(false)
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
                text: "About /r/" + linkManager.subreddit
                visible: linkManager.subreddit != "" && linkManager.subreddit.toLowerCase() != "all"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutSubredditPage.qml"), {subreddit: linkManager.subreddit});
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
        model: linkManager.model
        delegate: LinkDelegate {
            showSubreddit: linkManager.subreddit == ""
                           || linkManager.subreddit.toLowerCase() == "all"
        }
        footer: Item {
            width: ListView.view.width
            height: loadMoreButton.height + 2 * constant.paddingLarge
            visible: ListView.view.count > 0

            Button {
                id: loadMoreButton
                anchors.centerIn: parent
                enabled: !linkManager.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: linkManager.refresh(true);
            }
        }

        EmptyContentLabel { visible: linkListView.count == 0 && !linkManager.busy }
    }

    ScrollDecorator { flickableItem: linkListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: linkManager.title
        busy: linkManager.busy
        onClicked: linkListView.positionViewAtBeginning()
    }

    LinkManager {
        id: linkManager
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    SubredditManager {
        id: subscribedSubredditManager
        manager: quickdditManager
        section: SubredditManager.UserAsSubscriberSection
        onError: infoBanner.alert(errorString)
    }

    QtObject {
        id: dialogManager

        property Component __subredditDialogComponent: null
        property Component __searchDialogComponent: null
        property Component __sectionDialogComponent: null

        function createSubredditDialog() {
            if (!__subredditDialogComponent)
                __subredditDialogComponent = Qt.createComponent("SubredditDialog.qml");
            var p = {};
            if (quickdditManager.signedIn)
                p.subredditManager = subscribedSubredditManager;
            var dialog = __subredditDialogComponent.createObject(mainPage, p);
            if (!dialog) {
                console.log("Error creating object: " + __subredditDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                if (dialog.browseSubreddits) {
                    pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"));
                } else {
                    linkManager.subreddit = dialog.text;
                    linkManager.refresh(false);
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
                    if (dialog.type == 0)
                        pageStack.push(Qt.resolvedUrl("SearchPage.qml"), {query: dialog.text});
                    else
                        pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"), {searchQuery: dialog.text});
                } else {
                    infoBanner.alert("Please enter some text to search!");
                }
            })
        }

        function createSectionDialog() {
            if (!__sectionDialogComponent)
                __sectionDialogComponent = Qt.createComponent("SectionDialog.qml");
            var dialog = __sectionDialogComponent.createObject(mainPage);
            if (!dialog) {
                console.log("Error creating object: " + __sectionDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function() {
                linkManager.section =  dialog.selectedIndex;
                linkManager.refresh(false);
            })
        }
    }
}
