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
    title: "Search Result: " + searchModel.searchQuery
    busy: linkVoteManager.busy

    property alias searchQuery: searchModel.searchQuery

    readonly property variant sortModel: ["Relevance", "New", "Hot", "Top", "Comments"]
    readonly property variant timeRangeModel: ["All time", "This hour", "Today", "This week",
        "This month", "This year"]

    function refresh() {
        searchModel.refresh(false);
    }

    SilicaListView {
        id: searchListView
        anchors.fill: parent
        model: searchModel

        PullDownMenu {
            MenuItem {
                text: "Time Range"
                onClicked: {
                    globalUtils.createSelectionDialog("Time Range", timeRangeModel, searchModel.searchTimeRange,
                    function(selectedIndex) {
                        searchModel.searchTimeRange = selectedIndex;
                        searchModel.refresh(false);
                    })
                }
            }

            MenuItem {
                text: "Sort"
                onClicked: {
                    globalUtils.createSelectionDialog("Sort", sortModel, searchModel.searchSort,
                    function(selectedIndex) {
                        searchModel.searchSort = selectedIndex;
                        searchModel.refresh(false);
                    })
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: searchModel.refresh(false);
            }
        }

        header: PageHeader { title: searchPage.title }

        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showMenuOnPressAndHold: false
            showSubreddit: true
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: showMenu({link: model, linkVoteManager: linkVoteManager});
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
        onError: infoBanner.alert(errorString);
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        onVoteSuccess: searchModel.changeLikes(fullname, likes);
        onError: infoBanner.alert(errorString);
    }
}
