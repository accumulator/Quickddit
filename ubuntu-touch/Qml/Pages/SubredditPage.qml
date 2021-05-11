/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.12
import QtQuick.Controls 2.12
import quickddit.Core 1.0
import QtGraphicalEffects 1.0

import "../"
import "../Delegates"

Page {
    id:subredditPage
    title: "/r/"+subreddit
    objectName: "subredditPage"
    property string subreddit

    ScrollView{
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: logo.height + Math.max(headerImage.height,30) + subButton.height + showButton.height + about.height + wiki.height
        ScrollBar.vertical.interactive: false

        Image {
            id:headerImage
            anchors{left: parent.left;right: parent.right;top:parent.top}
            fillMode: Image.PreserveAspectFit
            source: aboutSubredditManager.bannerBackgroundUrl
        }

        CircleImage {
            id:logo
            source: aboutSubredditManager.iconUrl
            anchors{left: parent.left;top:headerImage.bottom; leftMargin: 20; topMargin: -Math.min(50,headerImage.height)}
            width: Math.min(150,parent.width/4)
            height: width
        }

        Label {
            id:fullName
            text: "/r/"+subreddit
            font.pointSize: 18
            anchors{ left: logo.right;bottom: name.top;leftMargin: 20}
        }

        Label {
            id:name
            text: aboutSubredditManager.title
            anchors{left: logo.right;bottom: logo.bottom;leftMargin: 20}
        }

        Button {
            anchors{top: logo.bottom;right: parent.right;margins: 5}
            id:subButton
            text: aboutSubredditManager.isSubscribed?qsTr("Unsubscribe"):qsTr("Subscribe")
            onClicked: {
                if(aboutSubredditManager.isSubscribed)
                    aboutSubredditManager.subscribeOrUnsubscribe()
                else
                    aboutSubredditManager.subscribeOrUnsubscribe()
            }
        }

        Label {
            id:subCount
            anchors{right: subButton.left;verticalCenter:  subButton.verticalCenter; margins: 5}
            text: aboutSubredditManager.activeUsers + " "+qsTr("active")+" / " + aboutSubredditManager.subscribers + " "+qsTr("subs")
        }

        Label {
            id:about
            anchors {left: parent.left;right: parent.right;top: subButton.bottom; margins:10}
            text: aboutSubredditManager.shortDescription
            wrapMode: "WordWrap"
        }

        Button {
            id:showButton
            text: qsTr("Show posts in")+" r/"+subreddit
            anchors { horizontalCenter: parent.horizontalCenter; top: about.bottom; margins: 10}
            onClicked: {
                globalUtils.getMainPage().refresh(subreddit)
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition)
            }
        }

        Label {
            id:wiki

            text: "<style>a {color: " + persistantSettings.primaryColor + " }</style>\n" + aboutSubredditManager.longDescription
            textFormat: Text.RichText
            anchors{ left: parent.left;top:showButton.bottom;right: parent.right;margins: 10}
            wrapMode: "WordWrap"
            onLinkActivated: globalUtils.openLink(link)
        }
    }

    AboutSubredditManager{
        id:aboutSubredditManager
        manager: quickdditManager
        subreddit: subredditPage.subreddit
    }
}
