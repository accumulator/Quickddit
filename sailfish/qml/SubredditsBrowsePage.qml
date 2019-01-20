/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2016  Sander van Grieken

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
    id: subredditsBrowsePage
    title: subredditModel.section == SubredditModel.SearchSection
           ? qsTr("Subreddits Search: %1").arg(searchQuery)
           : subredditsSectionModel[subredditModel.section]

    property alias searchQuery: subredditModel.query
    property bool isSearch: searchQuery

    property string _menusub
    property string _action

    readonly property variant subredditsSectionModel: [qsTr("Popular Subreddits"), qsTr("New Subreddits"),
        qsTr("My Subreddits - Subscriber"), qsTr("My Subreddits - Approved Submitter"), qsTr("My Subreddits - Moderator")]

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            if (subredditModel.rowCount() === 0)
                subredditModel.refresh(false)
        }
    }

    function refresh() {
        subredditModel.refresh(false);
    }

    SilicaListView {
        id: subredditsListView
        anchors.fill: parent
        model: subredditModel

        PullDownMenu {
            MenuItem {
                text: qsTr("Section")
                onClicked: {
                    globalUtils.createSelectionDialog(qsTr("Section"), subredditsSectionModel, subredditModel.section,
                    function(selectedIndex) {
                        subredditModel.section = selectedIndex;
                        subredditModel.refresh(false);
                    })
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: subredditModel.refresh(false);
            }
        }

        header: PageHeader { title: subredditsBrowsePage.title }

        delegate: SubredditBrowseDelegate {
            onClicked: {
                var mainPage = globalUtils.getMainPage();
                mainPage.refresh(model.displayName);
                pageStack.pop(mainPage);
            }

            showMenuOnPressAndHold: true

            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: qsTr("About")
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AboutSubredditPage.qml"), {subreddit: model.displayName} );
                        }
                    }
                    MenuItem {
                        text: qsTr("Subscribe")
                        visible: quickdditManager.isSignedIn && !model.isSubscribed
                        onClicked: {
                            _menusub = model.displayName
                            _action = "subscribed"
                            subredditManager.subscribe(model.fullname);
                        }
                    }
                    MenuItem {
                        text: qsTr("Unsubscribe")
                        visible: quickdditManager.isSignedIn && model.isSubscribed
                        onClicked: {
                            _menusub = model.displayName
                            _action = "unsubscribed"
                            subredditManager.unsubscribe(model.fullname);
                        }
                    }
                }
            }

            AltMarker { }
        }

        footer: LoadingFooter { visible: subredditModel.busy; listViewItem: subredditsListView }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !subredditModel.busy && subredditModel.canLoadMore)
                subredditModel.refresh(true);
        }

        ViewPlaceholder { enabled: subredditsListView.count == 0 && !subredditModel.busy; text: qsTr("Nothing here :(") }

        VerticalScrollDecorator {}
    }

    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        section: isSearch ? SubredditModel.SearchSection : SubredditModel.PopularSection
        onError: infoBanner.warning(errorString);
    }

    SubredditManager {
        id: subredditManager
        manager: quickdditManager
        model: subredditModel
        onSuccess: {
            infoBanner.alert(qsTr("You have %2 from %1").arg(_menusub).arg(_action))
        }
        onError: infoBanner.warning(errorString)
    }
}
