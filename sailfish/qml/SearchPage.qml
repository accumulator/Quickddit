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
    id: searchPage
    title: qsTr("Search Result: %1").arg(searchModel.searchQuery)
    busy: linkVoteManager.busy

    property alias searchQuery: searchModel.searchQuery
    property alias subreddit: searchModel.subreddit

    readonly property variant sortModel: [qsTr("Relevance"), qsTr("New"), qsTr("Hot"), qsTr("Top"), qsTr("Comments")]
    readonly property variant timeRangeModel: [qsTr("All time"), qsTr("This hour"), qsTr("Today"), qsTr("This week"),
        qsTr("This month"), qsTr("This year")]

    function refresh() {
        searchModel.refresh(false);
    }

    SilicaListView {
        id: searchListView
        anchors.fill: parent
        model: searchModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Search Again")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SearchDialog.qml"), {query: searchQuery, subreddit: subreddit});
                }
            }

            MenuItem {
                text: qsTr("Time Range")
                onClicked: {
                    globalUtils.createSelectionDialog(qsTr("Time Range"), timeRangeModel, searchModel.searchTimeRange,
                    function(selectedIndex) {
                        searchModel.searchTimeRange = selectedIndex;
                        searchModel.refresh(false);
                    })
                }
            }

            MenuItem {
                text: qsTr("Sort")
                onClicked: {
                    globalUtils.createSelectionDialog(qsTr("Sort"), sortModel, searchModel.searchSort,
                    function(selectedIndex) {
                        searchModel.searchSort = selectedIndex;
                        searchModel.refresh(false);
                    })
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: searchModel.refresh(false);
            }
        }

        header: QuickdditPageHeader { title: searchPage.title }

        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showMenuOnPressAndHold: false
            showSubreddit: true
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: openMenu({link: model, linkVoteManager: linkVoteManager});
        }

        footer: LoadingFooter { visible: searchModel.busy; listViewItem: searchListView }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !searchModel.busy && searchModel.canLoadMore)
                searchModel.refresh(true);
        }

        ViewPlaceholder { enabled: searchListView.count == 0 && !searchModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    LinkModel {
        id: searchModel
        location: LinkModel.Search
        manager: quickdditManager
        onError: infoBanner.warning(errorString);
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        onVoteSuccess: searchModel.changeLikes(fullname, likes);
        onError: infoBanner.warning(errorString);
    }
}
