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
import QtQuick.Layouts 1.2
import quickddit.Core 1.0
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import QtQuick.Controls.Suru 2.2
import "../"
import "../Delegates"


Page {

    id:mainPage
    objectName: "mainPage"
    title: linkModel.title

    property string subreddit
    property string duplicatesOf
    property string section
    property string sectionTimeRange
    property bool busy : linkModel.busy

    function refresh(sr, keepsection) {
        if (sr !== undefined) {
            // getting messy here :(
            // initialize section to undefined unless explicitly kept,
            // so the subreddit's default section is retrieved in the linkmodel
            if (keepsection === undefined || keepsection === false)
                linkModel.section = LinkModel.UndefinedSection
            linkModel.subreddit = "";
            if (sr === "") {
                linkModel.location = LinkModel.FrontPage;
            } else if (String(sr).toLowerCase() === "all") {
                linkModel.location = LinkModel.All;
            } else if (String(sr).toLowerCase() === "popular") {
                linkModel.location = LinkModel.Popular;
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
        linkModel.section = LinkModel.UndefinedSection
        linkModel.refresh(false);
    }

    function refreshDuplicates() {
        linkModel.location = LinkModel.Duplicates
        linkModel.section = LinkModel.UndefinedSection
        linkModel.subreddit = duplicatesOf
        linkModel.refresh(false)
    }

    function getButtons(){
        return toolButtons
    }

    function getLinkManager (){
        return linkManager
    }

    function onItemClicked(i) {
        var period = ["hour","day","week","month","year","all"]
        switch (period[i]) {
        case "hour": linkModel.sectionTimeRange = LinkModel.Hour; break;
        case "day": linkModel.sectionTimeRange = LinkModel.Day; break;
        case "week": linkModel.sectionTimeRange = LinkModel.Week; break;
        case "month": linkModel.sectionTimeRange = LinkModel.Month; break;
        case "year": linkModel.sectionTimeRange = LinkModel.Year; break;
        case "all": linkModel.sectionTimeRange = LinkModel.AllTime; break;
        }
        sectionTimeRange = period[i]
        linkModel.saveSubredditPrefs();
        linkModel.refresh(false)
    }

    Component {
        id: toolButtons
        Row {
            ActionButton {
                id:period
                ico: "qrc:/Icons/filters.svg"
                color: Suru.color(Suru.White,1)
                onClicked: {periodMenu.open()}
                enabled: (linkModel.section == LinkModel.TopSection || linkModel.section == LinkModel.ControversialSection)
                clip: true

                Menu {
                    id: periodMenu
                    y:parent.y+parent.height
                    MenuItem {
                        text: qsTr("Hour")
                        onClicked: onItemClicked(0)
                    }
                    MenuItem {
                        text: qsTr("Day")
                        onClicked: onItemClicked(1)
                    }
                    MenuItem {
                        text: qsTr("Week")
                        onClicked: onItemClicked(2)
                    }
                    MenuItem {
                        text: qsTr("Month")
                        onClicked: onItemClicked(3)
                    }
                    MenuItem {
                        text: qsTr("Year")
                        onClicked: onItemClicked(4)
                    }
                    MenuItem {
                        text: qsTr("All time")
                        onClicked: onItemClicked(5)
                    }
                }
            }

            ActionButton {
                id:info
                ico: "qrc:/Icons/info.svg"
                size: 20
                enabled: linkModel.location == LinkModel.Subreddit
                color: Suru.color(Suru.White,1)
                width: enabled ? 40 : 0
                clip: true
                onClicked: {pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SubredditPage.qml"),{subreddit:linkModel.subreddit})}
            }
            ActionButton {
                id:newPost
                ico: "qrc:/Icons/add.svg"
                size: 20
                enabled: quickdditManager.isSignedIn
                color: Suru.color(Suru.White,1)
                width: linkModel.location == LinkModel.Subreddit ? 40 : 0
                clip: true
                onClicked: {pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SendLinkPage.qml"), {linkManager: linkManager, subreddit: linkModel.subreddit})}
            }
        }
    }

    header:
        TabBar{
        id: tabBar
        contentHeight: undefined
        leftPadding: 10
        background: Rectangle {
            color: Suru.color(Suru.Orange,1)
        }

        TabButton {
            id:tb0
            text: qsTr("Best")
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: tb0.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6

        }
        TabButton {
            id:tb1
            text: qsTr("Hot")
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: parent.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6
        }
        TabButton {
            id:tb2
            text: qsTr("New")
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: parent.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6
        }
        TabButton {
            id:tb3
            text: qsTr("Rising")
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: parent.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6
        }
        TabButton {
            id:tb4
            text: qsTr("Controversial")
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: parent.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6
        }
        TabButton {
            id:tb5
            text: qsTr("Top")
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: parent.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6
        }



        onCurrentIndexChanged: {
            if(linkModel.section !== currentIndex) {
                linkModel.section = currentIndex
                linkModel.saveSubredditPrefs()
                linkModel.refresh(false)
            }
        }
    }

    Component {
        id:linkListComponent

        ListView {
            id: linkListView
            anchors.fill: parent
            model: linkModel
            cacheBuffer: height*3
            highlightFollowsCurrentItem: false

            Label {
                anchors { bottom: linkListView.contentItem.top; horizontalCenter: parent.horizontalCenter; margins: 75 }
                text: qsTr("Pull to refresh...")
            }


            delegate: LinkDelegate {
                linkSaveManager: saveManager
                linkVoteManager: voteManager
                id: linkDelegate
                link: model
                width: linkListView.width

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/CommentPage.qml"), {linkPermalink: model.permalink});
                }
            }

            onContentYChanged: {
                if(contentY<=-150 && !linkModel.busy)
                    linkModel.refresh(false)
            }

            onAtYEndChanged: {
                if (atYEnd && count > 0 && !linkModel.busy && linkModel.canLoadMore)
                    linkModel.refresh(true);
            }
            BusyIndicator {
                anchors.centerIn: parent
                running: linkListView.count==0
            }
        }
    }

    SwipeView{
        id: swipeView
        anchors.fill: parent

        Repeater {
            model: 6
            Loader {
                active: SwipeView.isCurrentItem
                sourceComponent: linkListComponent
            }
        }
        currentIndex: tabBar.currentIndex

        onCurrentIndexChanged: {
            tabBar.currentIndex = currentIndex

        }
    }

    LinkModel {
        id: linkModel
        manager: quickdditManager
        onError: infoBanner.warning(errorString)

        onSectionChanged: {
            if (linkModel.section != LinkModel.UndefinedSection && linkModel.section !=LinkModel.GildedSection)
                tabBar.setCurrentIndex(linkModel.section)
        }
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
        id: voteManager
        manager: quickdditManager
        onVoteSuccess: linkModel.changeLikes(fullname, likes);
        onError: infoBanner.warning(errorString);
    }

    SaveManager {
        id: saveManager
        manager: quickdditManager
        onSuccess: linkModel.changeSaved(fullname, saved);
        onError: infoBanner.warning(errorString);
    }

    Component.onCompleted: {
        if (section !== undefined) {
            var si = ["best", "hot", "new", "rising", "controversial", "top"].indexOf(section);
            if (si !== -1)
                linkModel.section = si;
            if (sectionTimeRange !== undefined && (si === 4 || si === 5)) {
                var ri = ["hour", "day", "week", "month", "year", "all"].indexOf(sectionTimeRange);
                if (ri !== -1)
                    linkModel.sectionTimeRange = ri
            }
        }
        if (duplicatesOf && duplicatesOf !== "") {
            refreshDuplicates()
            return
        }

        refresh(subreddit, true);
    }
}
