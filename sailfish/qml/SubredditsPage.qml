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

Page {
    id: subredditsPage

    readonly property string title: "Subreddits"
    property SubredditModel subredditModel

    function refresh(subreddit) {
        var mainPage = pageStack.find(function(page) { return page.objectName == "mainPage"; });
        mainPage.refresh(subreddit);
        pageStack.navigateBack();
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (quickdditManager.isSignedIn && !subredditModel)
                subredditModel = subredditModelComponent.createObject(subredditsPage);
        } else if (status == PageStatus.Inactive) {
            subredditTextField.text = "";
            subredditTextField.focus = false; // remove keyboard focus
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        pressDelay: 0

        PullDownMenu {
            enabled: !!subredditModel
            MenuItem {
                enabled: !!subredditModel && !subredditModel.busy
                text: "Refresh subscribed subreddits"
                onClicked: subredditModel.refresh(false);
            }
        }

        PageHeader {
            id: dialogHeader
            anchors { left: parent.left; right: parent.right; top: parent.top }
            title: subredditsPage.title
        }

        TextField {
            id: subredditTextField
            anchors { left: parent.left; right: parent.right; top: dialogHeader.bottom }
            placeholderText: "Go to a specific subreddit"
            labelVisible: false
            errorHighlight: activeFocus && !acceptableInput
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            // RegExp based on <https://github.com/reddit/reddit/blob/aae622d/r2/r2/lib/validator/validator.py#L525>
            validator: RegExpValidator { regExp: /^[A-Za-z0-9][A-Za-z0-9_]{2,20}$/ }
            EnterKey.enabled: acceptableInput
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: refresh(text);
        }

        Column {
            id: mainOptionColumn
            anchors { left: parent.left; right: parent.right; top: subredditTextField.bottom }
            height: childrenRect.height

            Repeater {
                id: mainOptionRepeater
                anchors { left: parent.left; right: parent.right }
                model: ["All", "Browse for Subreddits..."]

                SimpleListItem {
                    width: mainOptionRepeater.width
                    text: modelData
                    onClicked: {
                        switch (index) {
                        case 0: subredditsPage.refresh("all"); break;
                        case 1: pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml")); break;
                        }
                    }
                }
            }
        }

        SectionHeader {
            id: subscribedSubredditHeader
            anchors.top: mainOptionColumn.bottom
            visible: !!subredditModel
            text: "Subscribed Subreddits"
        }

        SilicaListView {
            id: subscribedSubredditListView
            anchors {
                top: subscribedSubredditHeader.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }
            pressDelay: 0
            visible: !!subredditModel
            clip: true
            model: visible ? subredditModel : 0
            delegate: SimpleListItem {
                text: model.url
                onClicked: subredditsPage.refresh(model.displayName);
            }

            footer: LoadingFooter {
                visible: !!subredditModel && subredditModel.busy
                listViewItem: subscribedSubredditListView
            }

            onAtYEndChanged: {
                if (atYEnd && count > 0 && !subredditModel.busy && subredditModel.canLoadMore)
                    subredditModel.refresh(true);
            }

            VerticalScrollDecorator {}
        }
    }

    Component {
        id: subredditModelComponent

        SubredditModel {
            manager: quickdditManager
            section: SubredditModel.UserAsSubscriberSection
            onError: infoBanner.alert(errorString);
        }
    }
}
