/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

AbstractPage {
    id: mainPage
    objectName: "mainPage"

    /*readonly*/ property variant sectionModel: ["Hot", "New", "Rising", "Controversial", "Top", "Promoted"]

    function refresh(subreddit) {
        if (subreddit !== undefined) {
            if (subreddit == "") {
                linkModel.location = LinkModel.FrontPage;
            } else if (String(subreddit).toLowerCase() === "all") {
                linkModel.location = LinkModel.All;
            } else {
                linkModel.location = LinkModel.Subreddit;
                linkModel.subreddit = subreddit;
            }
        }
        linkModel.refresh(false);
    }

    title: linkModel.title
    busy: linkVoteManager.busy
    onHeaderClicked: linkListView.positionViewAtBeginning();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back-dimmed"
            enabled: false
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: {
                globalUtils.createSelectionDialog("Section", sectionModel, linkModel.section,
                function(selectedIndex) {
                    linkModel.section =  selectedIndex;
                    linkModel.refresh(false);
                })
            }
        }
        ToolIcon {
            platformIconId: enabled ? "toolbar-refresh" : "toolbar-refresh-dimmed"
            enabled: !linkModel.busy
            onClicked: linkModel.refresh(false)
        }
        ToolIcon {
            iconSource: "image://theme/icon-l-user-guide-main-view"
            enabled: linkModel.location == LinkModel.Subreddit || linkModel.location == LinkModel.Multireddit
            opacity: enabled ? 1 : 0.25
            onClicked: {
                var page = "", p = {};
                if (linkModel.location == LinkModel.Subreddit) {
                    page = Qt.resolvedUrl("AboutSubredditPage.qml");
                    p = {subreddit: linkModel.subreddit};
                } else {
                    page = Qt.resolvedUrl("AboutMultiredditPage.qml");
                    p = {multireddit: linkModel.multireddit, model: dialogManager.multiredditModel};
                }
                pageStack.push(page, p);
            }
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
                text: "New Link"
                visible: linkModel.location == LinkModel.Subreddit
                onClicked: {
                    var p = {linkManager: linkManager, subreddit: linkModel.subreddit};
                    pageStack.push(Qt.resolvedUrl("NewLinkPage.qml"), p);
                }
            }

            MenuItem {
                text: "Subreddits"
                onClicked: dialogManager.createSubredditDialog();
            }
            MenuItem {
                text: "Multireddits"
                enabled: quickdditManager.isSignedIn
                onClicked: dialogManager.createMultiredditDialog();
            }
            MenuItem {
                text: "Messages"
                enabled: quickdditManager.isSignedIn
                onClicked: pageStack.push(Qt.resolvedUrl("MessagePage.qml"));
            }
            MenuItem {
                text: "Search"
                onClicked: dialogManager.createSearchDialog();
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
        anchors.fill: parent
        model: linkModel
        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showSubreddit: linkModel.location != LinkModel.Subreddit
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: showMenu({link: model, linkVoteManager: linkVoteManager});
        }

        footer: LoadingFooter { visible: linkModel.busy; listViewItem: linkListView }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !linkModel.busy && linkModel.canLoadMore)
                linkModel.refresh(true);
        }

        ViewPlaceholder { enabled: linkListView.count == 0 && !linkModel.busy }
    }

    ScrollDecorator { flickableItem: linkListView }

    LinkModel {
        id: linkModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    LinkManager {
        id: linkManager
        manager: quickdditManager
        linkModel: linkModel
        onSuccess: {
            infoBanner.alert(message);
            pageStack.pop();
        }
        onError: infoBanner.alert(errorString);
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        onVoteSuccess: linkModel.changeLikes(fullname, likes);
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __subredditDialogComponent: null
        property Component __multiredditDialogComponent: null
        property Component __searchDialogComponent: null

        property Component __subredditDialogModelComponent: Component {
            SubredditModel {
                manager: quickdditManager
                section: SubredditModel.UserAsSubscriberSection
                onError: infoBanner.alert(errorString);
            }
        }
        property QtObject __subredditDialogModel

        property Component __multiredditModelComponent: Component {
            MultiredditModel {
                manager: quickdditManager
                onError: infoBanner.alert(errorString);
            }
        }
        property QtObject multiredditModel

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
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed) {
                    dialog.destroy(250);
                }
            });
            dialog.accepted.connect(function() {
                if (dialog.browseSubreddits) {
                    pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"));
                } else {
                    mainPage.refresh(dialog.subreddit);
                }
            });
            dialog.open();
        }

        function createMultiredditDialog() {
            if (!__multiredditDialogComponent)
                __multiredditDialogComponent = Qt.createComponent("MultiredditDialog.qml");
            if (!multiredditModel)
                multiredditModel = __multiredditModelComponent.createObject(mainPage);
            var dialog = __multiredditDialogComponent.createObject(mainPage, {multiredditModel: multiredditModel});
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed) {
                    dialog.destroy(250);
                }
            });
            dialog.accepted.connect(function() {
                linkModel.location = LinkModel.Multireddit;
                linkModel.multireddit = dialog.multiredditName;
                linkModel.refresh(false);
            })
            dialog.open();
        }

        function createSearchDialog() {
            if (!__searchDialogComponent)
                __searchDialogComponent = Qt.createComponent("SearchDialog.qml");
            var p = {};
            if (linkModel.location == LinkModel.Subreddit)
                p.subreddit = linkModel.subreddit;
            var dialog = __searchDialogComponent.createObject(mainPage, p);
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed) {
                    dialog.destroy(250);
                }
            });
            dialog.accepted.connect(function() {
                var p = { searchQuery: dialog.text };
                if (dialog.type == 0) {
                    if (dialog.searchSubreddit)
                        p.subreddit = dialog.subreddit;
                    pageStack.push(Qt.resolvedUrl("SearchPage.qml"), p);
                } else {
                    pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"), p);
                }
            });
            dialog.open();
        }
    }
}
