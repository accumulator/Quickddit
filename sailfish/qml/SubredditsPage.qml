/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2014  Sander van Grieken

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
    id: subredditsPage

    readonly property string title: "Subreddits"
    property SubredditModel subredditModel

    property string _unsubsub

    function showSubreddit(subreddit) {
        var mainPage = globalUtils.getMainPage();
        mainPage.refresh(subreddit);
        pageStack.navigateBack();
    }

    function replacePage(newpage, parms) {
        var mainPage = globalUtils.getMainPage();
        mainPage.__pushedAttached = false;
        pageStack.replaceAbove(mainPage, newpage, parms);
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (!subredditModel)
                subredditModel = subredditModelComponent.createObject(subredditsPage);
        } else if (status === PageStatus.Inactive) {
            subredditListView.headerItem.resetTextField();
            subredditListView.positionViewAtBeginning();
        }
    }

    SilicaListView {
        id: subredditListView
        anchors.fill: parent
        model: subredditModel

        PullDownMenu {
            MenuItem {
                text: "About Quickddit"
                onClicked: replacePage(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: "Settings"
                onClicked: replacePage(Qt.resolvedUrl("AppSettingsPage.qml"))
            }

            MenuItem {
                enabled: quickdditManager.isSignedIn
                text: "My Profile"
                onClicked: replacePage(Qt.resolvedUrl("UserPage.qml"), {username: appSettings.redditUsername});
            }

            MenuItem {
                enabled: quickdditManager.isSignedIn
                text: "Messages"
                onClicked: replacePage(Qt.resolvedUrl("MessagePage.qml"));
            }
        }

        header: Column {
            anchors { left: parent.left; right: parent.right }

            function resetTextField() {
                subredditTextField.text = "";
                subredditTextField.focus = false; // remove keyboard focus
            }

            QuickdditPageHeader { title: subredditsPage.title }

            TextField {
                id: subredditTextField
                anchors { left: parent.left; right: parent.right }
                placeholderText: "Go to a specific subreddit"
                labelVisible: false
                errorHighlight: activeFocus && !acceptableInput
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                // RegExp based on <https://github.com/reddit/reddit/blob/aae622d/r2/r2/lib/validator/validator.py#L525>
                validator: RegExpValidator { regExp: /^([A-Za-z0-9][A-Za-z0-9_]{2,20}|[a-z]{2})$/ }
                EnterKey.enabled: acceptableInput
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: showSubreddit(text);
            }

            Repeater {
                id: mainOptionRepeater
                anchors { left: parent.left; right: parent.right }
                model: ["Front Page", "All", "Browse for Subreddits...", "Multireddits"]

                SimpleListItem {
                    width: mainOptionRepeater.width
                    enabled: index == 3 ? quickdditManager.isSignedIn : true
                    text: modelData
                    onClicked: {
                        switch (index) {
                        case 0: subredditsPage.showSubreddit(""); break;
                        case 1: subredditsPage.showSubreddit("all"); break;
                        case 2: pageStack.push(Qt.resolvedUrl("SubredditsBrowsePage.qml")); break;
                        case 3: pageStack.push(Qt.resolvedUrl("MultiredditsPage.qml")); break;
                        }
                    }
                }
            }

            SectionHeader {
                id: sectionheader
                visible: quickdditManager.isSignedIn
                text: "Subscribed Subreddits"

                MouseArea {
                    anchors.fill: sectionheader
                    onClicked: subredditModel.refresh(false);
                }
            }

        }

        delegate: SimpleListItem {
            id: itemDelegate
            text: model.url
            onClicked: subredditsPage.showSubreddit(model.displayName);

            showMenuOnPressAndHold: true

            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: "About"
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AboutSubredditPage.qml"), {subreddit: model.displayName} );
                        }
                    }
                    MenuItem {
                        text: "Unsubscribe"
                        onClicked: {
                            _unsubsub = model.displayName
                            subredditManager.unsubscribe(model.fullname);
                        }
                    }
                }
            }
        }

        footer: LoadingFooter {
            visible: !!subredditModel && subredditModel.busy
            listViewItem: subredditListView
        }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && quickdditManager.isSignedIn && !!subredditModel && !subredditModel.busy && subredditModel.canLoadMore)
                subredditModel.refresh(true);
        }

        add: Transition {
            NumberAnimation {
                properties: "opacity"
                from: 0; to: 1
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        VerticalScrollDecorator {}
    }

    Component {
        id: subredditModelComponent

        SubredditModel {
            manager: quickdditManager
            section: SubredditModel.UserAsSubscriberSection
            onError: infoBanner.warning(errorString);
        }
    }

    Connections {
        target: quickdditManager
        onSignedInChanged: {
            subredditModel = subredditModelComponent.createObject(subredditsPage);
        }
    }

    SubredditManager {
        id: subredditManager
        manager: quickdditManager
        model: subredditModel
        onSuccess: {
            infoBanner.alert(qsTr("You have unsubscribed from %1").arg(_unsubsub))
        }
        onError: infoBanner.warning(errorString)
    }

}
