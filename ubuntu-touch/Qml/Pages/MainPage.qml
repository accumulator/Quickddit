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
    title: linkModel.location == LinkModel.Multireddit ? /m/+subreddit : /r/+subreddit

    property string subreddit: quickdditManager.isSignedIn ? "subscribed" : "all"

    function refresh(sr) {
        if(sr===undefined|| sr===""){
            if(quickdditManager.isSignedIn){
                sr="subscribed"
            }
            else
                sr="all"
        }

        if ( String(sr).toLowerCase() === "subscribed") {
            linkModel.location = LinkModel.FrontPage;
        } else if (String(sr).toLowerCase() === "all") {
            linkModel.location = LinkModel.All;
        } else if (String(sr).toLowerCase() === "popular") {
            linkModel.location = LinkModel.Popular;
        } else {
            linkModel.location = LinkModel.Subreddit;
            linkModel.subreddit = sr;
        }
        subreddit=sr;
        linkModel.refresh(false);
    }

    function refreshMR(multireddit) {
        linkModel.location = LinkModel.Multireddit;
        linkModel.multireddit = multireddit
        subreddit = multireddit
        linkModel.refresh(false);
    }

    function getButtons(){
        return toolButtons
    }

    function getLinkManager (){
        return linkManager
    }

    function onItemClicked(i) {
        var period = ["hour","day","week","month","year","all"]
        linkModel.sectionPeriod = period[i]
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
                        text: "Hour"
                        onClicked: onItemClicked(0)
                    }
                    MenuItem {
                        text: "Day"
                        onClicked: onItemClicked(1)
                    }
                    MenuItem {
                        text: "Week"
                        onClicked: onItemClicked(2)
                    }
                    MenuItem {
                        text: "Month"
                        onClicked: onItemClicked(3)
                    }
                    MenuItem {
                        text: "Year"
                        onClicked: onItemClicked(4)
                    }
                    MenuItem {
                        text: "All time"
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
                onClicked: {pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SubredditPage.qml"),{subreddit:subreddit})}
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
            text: "Best"
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
            text: "Hot"
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
            text: "New"
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
            text: "Top"
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
            text: "Rising"
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
            text: "Controversial"
            contentItem: Label {
                text: parent.text
                font.weight: Font.Normal
                color: parent.checked ? Suru.color(Suru.White,1) : Suru.color(Suru.Porcelain,1)
            }
            width: implicitWidth
            padding:6
        }


        onCurrentIndexChanged: {
            console.log(currentIndex)
            tabBar.setCurrentIndex(currentIndex)
            switch(currentIndex){
            case 0: linkModel.section = LinkModel.BestSection; break
            case 1: linkModel.section = LinkModel.HotSection; break
            case 2: linkModel.section = LinkModel.NewSection; break
            case 3: linkModel.section = LinkModel.TopSection; break
            case 4: linkModel.section = LinkModel.RisingSection; break
            case 5: linkModel.section = LinkModel.ControversialSection; break
            }

            refresh(subreddit)
        }
    }

    Component {
        id:linkListComponent

        ListView{
            id: linkListView
            anchors.fill: parent
            model: linkModel
            cacheBuffer: height*3
            highlightFollowsCurrentItem: false

            Label {
                anchors { bottom: linkListView.contentItem.top; horizontalCenter: parent.horizontalCenter; margins: 75 }
                text: "Pull to refresh..."
            }

            delegate: LinkDelegate{
                linkSaveManager: saveManager
                linkVoteManager: voteManager
                id:linkDelegate
                link:model
                highlighted: false

                onClicked: {
                    var p = { link: model,linkVoteManager1: voteManager, linkSaveManager1:saveManager};
                    pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/CommentPage.qml"), p);
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
    linkModel.section=0
    linkModel.sectionPeriod= "day"
}
}
