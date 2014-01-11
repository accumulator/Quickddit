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

    /*readonly*/ property variant sectionModel: ["Hot", "New", "Rising", "Controversial", "Top"]

    function refresh(subreddit) {
        linkModel.subreddit = subreddit;
        linkModel.refresh(false);
    }

    title: linkModel.title
    busy: linkModel.busy || linkVoteManager.busy
    onHeaderClicked: linkListView.positionViewAtBeginning();

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
                onClicked: {
                    globalUtils.createSelectionDialog("Section", sectionModel, linkModel.section,
                    function(selectedIndex) {
                        linkModel.section =  selectedIndex;
                        linkModel.refresh(false);
                    })
                }
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
        anchors.fill: parent
        model: linkModel
        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showSubreddit: linkModel.subreddit == ""
                           || linkModel.subreddit.toLowerCase() == "all"
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
                enabled: !linkModel.busy
                width: parent.width * 0.75
                text: "Load More"
                onClicked: linkModel.refresh(true);
            }
        }

        ViewPlaceholder { enabled: linkListView.count == 0 && !linkModel.busy }
    }

    ScrollDecorator { flickableItem: linkListView }

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
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed) {
                    dialog.destroy(250);
                }
            });
            dialog.accepted.connect(function() {
                if (dialog.browseSubreddits) {
                    pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"));
                } else {
                    linkModel.subreddit = dialog.text;
                    linkModel.refresh(false);
                }
            });
            dialog.open();
        }

        function createSearchDialog() {
            if (!__searchDialogComponent)
                __searchDialogComponent = Qt.createComponent("SearchDialog.qml");
            var dialog = __searchDialogComponent.createObject(mainPage);
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed) {
                    dialog.destroy(250);
                }
            });
            dialog.accepted.connect(function() {
                var p = { searchQuery: dialog.text };
                if (dialog.type == 0)
                    pageStack.push(Qt.resolvedUrl("SearchPage.qml"), p);
                else
                    pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml"), p);

            });
            dialog.open();
        }
    }
}
