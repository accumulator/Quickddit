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

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: mainPage
    objectName: "mainPage"
    title: linkModel.title
    busy: linkVoteManager.busy

    readonly property variant sectionModel: ["Hot", "New", "Rising", "Controversial", "Top"]

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
    function __openMultiredditDialog() {
        if (!multiredditModel)
            multiredditModel = __multiredditModelComponent.createObject(mainPage);
        var dialog = pageStack.replace(Qt.resolvedUrl("MultiredditDialog.qml"), {multiredditModel: multiredditModel});
        dialog.accepted.connect(function() {
            linkModel.location = LinkModel.Multireddit;
            linkModel.multireddit = dialog.multiredditName;
            linkModel.refresh(false);
        });
    }

    SilicaListView {
        id: linkListView
        anchors.fill: parent
        model: linkModel

        PullDownMenu {
            MenuItem {
                text: "More"
                onClicked: {
                    var p = {};
                    if (linkModel.location == LinkModel.Subreddit)
                        p.currentSubreddit = linkModel.subreddit;
                    var page = pageStack.push(Qt.resolvedUrl("MainPageMorePage.qml"), p);
                    page.multiredditsClicked.connect(__openMultiredditDialog);
                }
            }
            MenuItem {
                text: "Subreddits"
                onClicked: {
                    var p = {}
                    if (quickdditManager.isSignedIn) {
                        if (!__subredditDialogModel)
                            __subredditDialogModel = __subredditDialogModelComponent.createObject(mainPage);
                        p.subredditModel = __subredditDialogModel;
                    }
                    var dialog = pageStack.push(Qt.resolvedUrl("SubredditDialog.qml"), p);
                    dialog.accepted.connect(function() {
                        if (!dialog.acceptDestination)
                            refresh(dialog.text);
                    });
                }
            }

            MenuItem {
                text: "Front Page"
                visible: linkModel.location != LinkModel.FrontPage
                onClicked: mainPage.refresh("");
            }
            MenuItem {
                text: "About " + (linkModel.location == LinkModel.Subreddit ? "/r/" + linkModel.subreddit
                                                                            : "/m/" + linkModel.multireddit)
                visible: linkModel.location == LinkModel.Subreddit || linkModel.location == LinkModel.Multireddit
                onClicked: {
                    var page = "", p = {};
                    if (linkModel.location == LinkModel.Subreddit) {
                        page = Qt.resolvedUrl("AboutSubredditPage.qml");
                        p = {subreddit: linkModel.subreddit};
                    } else {
                        page = Qt.resolvedUrl("AboutMultiredditPage.qml");
                        p = {multireddit: linkModel.multireddit, model: multiredditModel};
                    }
                    pageStack.push(page, p);
                }
            }
            MenuItem {
                text: "Section"
                onClicked: {
                    globalUtils.createSelectionDialog("Section", sectionModel, linkModel.section,
                    function(selectedIndex) {
                        linkModel.section = selectedIndex;
                        linkModel.refresh(false);
                    });
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: linkModel.refresh(false);
            }
        }

        header: PageHeader { title: mainPage.title }

        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showMenuOnPressAndHold: false
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

        ViewPlaceholder { enabled: linkListView.count == 0 && !linkModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    LinkModel {
        id: linkModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        onVoteSuccess: linkModel.changeLikes(fullname, likes);
        onError: infoBanner.alert(errorString);
    }
}
