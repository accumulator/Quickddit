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

import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Suru 2.2
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
        contentHeight: logo.height + Math.max(headerImage.height,Suru.units.gu(4)) + subButton.height + showButton.height + about.height + wiki.height
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
            anchors{left: parent.left;top:headerImage.bottom; leftMargin: Suru.units.gu(3); topMargin: -Math.min(Suru.units.gu(6),headerImage.height)}
            width: Math.min(Suru.units.gu(18),parent.width/4)
            height: width
        }

        Label {
            id:fullName
            text: "/r/"+subreddit
            font.pixelSize: Suru.units.rem(1)
            anchors{ left: logo.right;bottom: name.top;leftMargin: Suru.units.gu(3)}
        }

        Label {
            id:name
            text: aboutSubredditManager.title
            anchors{left: logo.right;bottom: logo.bottom;leftMargin: Suru.units.gu(3)}
        }

        Button {
            anchors{top: logo.bottom;right: parent.right;margins: Suru.units.gu(1)}
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
            anchors{right: subButton.left;verticalCenter:  subButton.verticalCenter; margins: Suru.units.gu(1)}
            text: aboutSubredditManager.activeUsers + " "+qsTr("active")+" / " + aboutSubredditManager.subscribers + " "+qsTr("subs")
        }

        Label {
            id:about
            anchors {left: parent.left;right: parent.right;top: subButton.bottom; margins:Suru.units.gu(2) }
            text: aboutSubredditManager.shortDescription
            wrapMode: "WordWrap"
        }

        Button {
            id:showButton
            text: qsTr("Show posts in")+" r/"+subreddit
            anchors { horizontalCenter: parent.horizontalCenter; top: about.bottom; margins: Suru.units.gu(2)}
            onClicked: {
                globalUtils.getMainPage().refresh(subreddit)
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition)
            }
        }

        Label {
            id:wiki

            color: Suru.foregroundColor
            linkColor: Suru.color(Suru.Orange,1)

            text: "<style>a {color: #e95420 }</style>\n" + aboutSubredditManager.longDescription
            textFormat: Text.RichText
            anchors{ left: parent.left;top:showButton.bottom;right: parent.right;margins: Suru.units.gu(2)}
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
