/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2017  Sander van Grieken

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

    property string subreddit
    property string section

    function refresh(sr) {
        if (sr !== undefined) {
            linkModel.subreddit = "";
            if (sr === "") {
                linkModel.location = LinkModel.FrontPage;
            } else if (String(sr).toLowerCase() === "all") {
                linkModel.location = LinkModel.All;
            } else {
                linkModel.location = LinkModel.Subreddit;
                linkModel.subreddit = sr;
            }
        }
        linkModel.refresh(false);
    }

    function refreshMR(multireddit) {
        linkModel.location = LinkModel.Multireddit;
        linkModel.multireddit = multireddit
        linkModel.refresh(false);
    }

    function newLink() {
        var p = {linkManager: linkManager, subreddit: linkModel.subreddit};
        pageStack.push(Qt.resolvedUrl("SendLinkPage.qml"), p);
    }

    function pushSectionDialog(title, selectedIndex, onAccepted) {
        var p = {title: title, selectedIndex: selectedIndex}
        var dialog = pageStack.push(Qt.resolvedUrl("SectionSelectionDialog.qml"), p);
        dialog.accepted.connect(function() {
            onAccepted(dialog.selectedIndex, dialog.periodQuery);
        })

    }

    property bool __pushedAttached: false

    onStatusChanged: {
        if (mainPage.status === PageStatus.Active && !__pushedAttached) {
            // get subredditspage and push
            pageStack.pushAttached(globalUtils.getNavPage());
            __pushedAttached = true;
        }
    }

    SilicaListView {
        id: linkListView
        anchors.fill: parent
        model: linkModel

        PullDownMenu {
            MenuItem {
                text: "About " + (linkModel.location == LinkModel.Subreddit ? "/r/" + linkModel.subreddit
                                                                            : "/m/" + linkModel.multireddit)
                visible: linkModel.location == LinkModel.Subreddit || linkModel.location == LinkModel.Multireddit
                onClicked: {
                    if (linkModel.location == LinkModel.Subreddit) {
                        pageStack.push(Qt.resolvedUrl("AboutSubredditPage.qml"), {subreddit: linkModel.subreddit});
                    } else {
                        pageStack.push(Qt.resolvedUrl("AboutMultiredditPage.qml"), {multireddit: linkModel.multireddit});
                    }
                }
            }
            MenuItem {
                text: qsTr("New Post")
                visible: linkModel.location == LinkModel.Subreddit
                enabled: quickdditManager.isSignedIn
                onClicked: newLink();
            }
            MenuItem {
                text: qsTr("Section")
                onClicked: {
                    pushSectionDialog(qsTr("Section"), linkModel.section,
                        function(selectedIndex, periodQuery) {
                            linkModel.section = selectedIndex;
                            linkModel.sectionPeriod = periodQuery;
                            appSettings.subredditSection = selectedIndex;
                            linkModel.refresh(false);
                        });
                }
            }
            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchDialog.qml"), {subreddit: linkModel.subreddit});
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: linkModel.refresh(false);
            }
        }

        header: QuickdditPageHeader { title: mainPage.title }

        delegate: LinkDelegate {
            id: linkDelegate

            menu: Component { LinkMenu {} }
            showMenuOnPressAndHold: false
            showSubreddit: linkModel.location != LinkModel.Subreddit

            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager, linkSaveManager: linkSaveManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }

            onPressAndHold: {
                var dialog = showMenu({link: model, linkVoteManager: linkVoteManager, linkSaveManager: linkSaveManager});
                dialog.deleteLink.connect(function() {
                    linkDelegate.remorseAction(qsTr("Delete link"), function() {
                        linkManager.deleteLink(model.fullname);
                    })
                });
            }

            AltMarker { }
        }

        footer: LoadingFooter {
            visible: linkModel.busy || (linkListView.count > 0 && linkModel.canLoadMore)
            running: linkModel.busy
            listViewItem: linkListView
        }

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
        onError: infoBanner.warning(errorString)
    }

    LinkManager {
        id: linkManager
        manager: quickdditManager
        linkModel: linkModel
        onSuccess: {
            infoBanner.alert(message);
            pageStack.pop();
        }
        onError: infoBanner.warning(errorString);
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        onVoteSuccess: linkModel.changeLikes(fullname, likes);
        onError: infoBanner.warning(errorString);
    }

    SaveManager {
        id: linkSaveManager
        manager: quickdditManager
        onSuccess: linkModel.changeSaved(fullname, saved);
        onError: infoBanner.warning(errorString);
    }

    Component.onCompleted: {
        if (subreddit == undefined)
            return;
        if (section !== undefined) {
            var si = ["hot", "new", "rising", "controversial", "top", "ads"].indexOf(section);
            if (si !== -1)
                linkModel.section = si;
        }
        refresh(subreddit);
    }
}
