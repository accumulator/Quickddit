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
import QtQuick.Layouts 1.12
import quickddit.Core 1.0

import "../"
import "../Delegates"

Page {
    title: qsTr("Subreddits")

    property string  section
    objectName: "subredditsPage"

    header: Item {
        width: parent.width
        height: tabBar.height+(search.visible?search.height:0)

        TabBar {
            id: tabBar
            width: parent.width
            currentIndex: swipeView.currentIndex
            leftPadding: 10

            TabButton {
                id: subButton
                text: qsTr("Subscribed")
                width: visible ? implicitWidth : 0
                visible: quickdditManager.isSignedIn

                onVisibleChanged: {
                    if (visible){
                        tabBar.insertItem(0,subButton)
                    }
                    else
                        parent = 0
                }
                padding: 6
            }

            TabButton {
                id: multiButton
                text: qsTr("Multireddits")
                width: visible ? implicitWidth : 0
                visible: quickdditManager.isSignedIn

                onVisibleChanged: {
                    if (visible){
                        tabBar.insertItem(1,multiButton)
                    }
                    else
                        parent = 0
                }
                padding: 6
            }

            TabButton {
                text: qsTr("Popular")
                padding: 6
                width: implicitWidth
            }
            TabButton {
                text: qsTr("New")
                padding: 6
                width: implicitWidth

            }
            TabButton {
                text: qsTr("Search")
                padding: 6
                width: implicitWidth
            }
            onCurrentIndexChanged: {
                swipeView.setCurrentIndex(currentIndex)

                switch(currentItem.text){
                case "Subscribed":
                    subredditModel.section=SubredditModel.UserAsSubscriberSection;
                    break;
                case "Popular":
                    subredditModel.section=SubredditModel.PopularSection
                    break;
                case "New":
                    subredditModel.section=SubredditModel.NewSection
                    break;
                case "Search":
                    subredditModel.section=SubredditModel.SearchSection
                    subredditModel.query=" "
                    subredditModel.clear()
                    search.forceActiveFocus()
                    break;
                }
                if (currentIndex!=1) {
                    subredditsView.parent=swipeView.currentItem
                    subredditModel.refresh(false)
                    console.log(subredditModel.section)
                }
                else {
                    multiredditModel.refresh(false)
                }

                section=currentItem.text
            }
        }

        TextField {
            id:search
            visible: section==="Search"
            anchors.top: tabBar.bottom
            width: parent.width
            text: ""
            onTextEdited: {
                subredditModel.query=" "+text
                subredditModel.refresh(false)
            }
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Item {
            ListView {

                anchors.fill: parent
                id:subredditsView
                model: subredditModel

                delegate: SubredditDelegate{
                    id:subredditDelegate
                    width: subredditsView.width

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SubredditPage.qml"),{subreddit:model.displayName})
                    }
                }
                onAtYEndChanged: {
                    if (atYEnd && count > 0 && !subredditModel.busy && subredditModel.canLoadMore)
                        subredditModel.refresh(true);
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: subredditsView.count==0
                }
            }
        }
        ListView {
            id:multiredditVIew
            model: multiredditModel

            delegate: MultiredditDelegate {
                id:multiredditDelegate

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/MultiredditPage.qml"),{multireddit:model.name,mrModel:multiredditModel})
                }
            }
            onAtYEndChanged: {
                if (atYEnd && count > 0 && !multiredditModel.busy && multiredditModel.canLoadMore)
                    multiredditModel.refresh(true);
            }

            BusyIndicator {
                anchors.centerIn: parent
                running: multiredditVIew.count==0
            }
        }

        Item{}
        Item{}
        Item{}
    }


    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        section: SubredditModel.UserAsSubscriberSection
        onError: infoBanner.warning(errorString);
    }

    SubredditManager {
        id: subredditManager
        manager: quickdditManager
        //onSuccess: linkModel.changeSaved(fullname, saved);
        onError: infoBanner.warning(errorString);
    }

    MultiredditModel {
        id: multiredditModel
        manager: quickdditManager
        onError: infoBanner.warning(errorString);
    }

    Connections {
        target: quickdditManager

        onSignedInChanged: {
            if (quickdditManager.isSignedIn) {
                // only load the list if there is an existing list (otherwise wait for page to activate, see above)
                if (subredditModel.rowCount() === 0)
                    return;
                subredditModel.refresh(false)
                multiredditModel.refresh(false)
            } else {
                subredditModel.clear();
                multiredditModel.clear();
            }
        }
    }
    Component.onCompleted:
    {
        quickdditManager.isSignedIn ? tabBar.setCurrentIndex(0) : tabBar.setCurrentIndex(2)
        subredditModel.refresh(false)
    }

    function showSubreddit(subreddit) {
        var mainPage = globalUtils.getMainPage();
        mainPage.refresh(subreddit);
        pageStack.navigateBack();
    }

    function getMultiredditModel() {
        return multiredditModel
    }
}
