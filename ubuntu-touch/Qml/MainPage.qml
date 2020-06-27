import QtQuick 2.9
import QtQuick.Layouts 1.2
import quickddit.Core 1.0
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0

Page {

    id:mainPage
    objectName: "mainPage"
    title: /r/+subreddit

    property string subreddit: quickdditManager.isSignedIn ? "subscribed" : "all"
    property string section

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
        subreddit = "/m/"+multireddit
        linkModel.refresh(false);
    }


    header:
        TabBar{
        id: tabBar
        contentHeight: undefined
        leftPadding: 10

        TabButton {
            id:tb0
            text: "Hot"
            width: implicitWidth
            padding:6
        }
        TabButton{
            id:tb1
            text: "New"
            width: implicitWidth
            padding:6
        }
        TabButton{
            id:tb2
            text: "Top"
            width: implicitWidth
            padding:6
        }
        TabButton{
            id:tb3
            text: "Controversial"
            width: implicitWidth
            padding:6
        }
        TabButton{
            id:tb4
            text: "Rising"
            width: implicitWidth
            padding:6
        }

        onCurrentIndexChanged: {
            swipeView.setCurrentIndex(currentIndex)
        }
    }


    SwipeView{
        id: swipeView
        anchors.fill: parent

        Item{id:item0

            ListView{
                id: linkListView
                anchors.fill: parent
                model: linkModel
                cacheBuffer: height*3

                Label {
                    anchors { bottom: linkListView.contentItem.top; horizontalCenter: parent.horizontalCenter; margins: 75 }
                    text: "Pull to refresh..."
                }

                delegate: LinkDelegate{
                    linkSaveManager: saveManager
                    linkVoteManager: voteManager
                    id:linkDelegate
                    link:model

                    onClicked: {
                        var p = { link: model,linkVoteManager1: voteManager, linkSaveManager1:saveManager};
                        pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
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
        Item{id:item1}
        Item{id:item2}
        Item{id:item3}
        Item{id:item4}
        onCurrentIndexChanged: {
            tabBar.setCurrentIndex(currentIndex)
            linkModel.section=currentIndex
            refresh(subreddit)
        }
        onCurrentItemChanged: {
            linkListView.parent=currentItem

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
    }
}
