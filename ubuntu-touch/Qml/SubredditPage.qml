import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import QtGraphicalEffects 1.0

Page {
    id:subredditPage
    title: subreddit
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
            text: subreddit
            font.pointSize: 18
            anchors{ left: logo.right;bottom: name.top;leftMargin: 20}
        }

        Label {
            id:name
            text: "r/"+aboutSubredditManager.subreddit
            anchors{left: logo.right;bottom: logo.bottom;leftMargin: 20}
        }

        Button {
            anchors{top: logo.bottom;right: parent.right;margins: 5}
            id:subButton
            text: aboutSubredditManager.isSubscribed?"Unsubscribe":"Subscribe"
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
            text: aboutSubredditManager.activeUsers + " active / " + aboutSubredditManager.subscribers + " subs"
        }

        Label {
            id:about
            anchors {left: parent.left;right: parent.right;top: subButton.bottom; margins:10}
            text: aboutSubredditManager.shortDescription
            wrapMode: "WordWrap"
        }

        Button {
            id:showButton
            text: "Show posts in r/"+subreddit
            anchors { horizontalCenter: parent.horizontalCenter; top: about.bottom; margins: 10}
            onClicked: {
                globalUtils.getMainPage().refresh(subreddit)
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition)
            }
        }

        Label {
            id:wiki
            text: aboutSubredditManager.longDescription
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
