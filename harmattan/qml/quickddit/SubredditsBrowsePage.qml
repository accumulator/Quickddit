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
    id: subredditsBrowsePage

    property alias searchQuery: subredditModel.query

    /*readonly*/ property variant subredditsSectionModel: ["Popular Subreddits", "New Subreddits",
        "My Subreddits - Subscriber", "My Subreddits - Approved Submitter", "My Subreddits - Moderator"]

    title: {
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
    onHeaderClicked: subredditsListView.positionViewAtBeginning();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: {
                globalUtils.createSelectionDialog("Section", subredditsSectionModel, subredditModel.section,
                function(selectedIndex) {
                    subredditModel.section = selectedIndex;
                    subredditModel.refresh(false);
                })
            }
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: subredditModel.refresh(false);
        }
    }

    ListView {
        id: subredditsListView
        anchors.fill: parent
        model: subredditModel
        delegate: SubredditDelegate {
            onClicked: {
                var mainPage = pageStack.find(function(page) { return page.objectName == "mainPage"; });
                mainPage.refresh(model.displayName);
                pageStack.pop(mainPage);
            }
        }
        footer: LoadMoreButton {
            visible: ListView.view.count > 0 && subredditModel.canLoadMore
            enabled: !subredditModel.busy
            onClicked: subredditModel.refresh(true);
        }

        ViewPlaceholder { enabled: subredditsListView.count == 0 && !subredditModel.busy }
    }

    ScrollDecorator { flickableItem: subredditsListView }

    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        section: searchQuery ? SubredditModel.SearchSection : SubredditModel.PopularSection
        onError: infoBanner.alert(errorString);
    }
}
