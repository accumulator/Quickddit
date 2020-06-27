import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

Drawer {
    id:subredditsDrawer
    height: window.height
    width: 250
    dragMargin: 0
    property bool signedIn: false
    function showSubreddit(subreddit) {
        var mainPage = globalUtils.getMainPage();
        mainPage.refresh(subreddit.slice(3));
    }

    ListView{
        anchors.fill: parent
        id:subredditsView
        model: subredditModel
        header:Column{
            width: parent.width
            ItemDelegate{
                text: "/r/subscribed"
                width: parent.width
                visible: quickdditManager.isSignedIn || subredditsDrawer.position<0.1
                onClicked: {
                    showSubreddit(text);
                    subredditsDrawer.close();
                }
            }
            ItemDelegate{
                text: "/r/all"
                width: parent.width
                onClicked: {
                    showSubreddit(text);
                    subredditsDrawer.close();
                }
            }
            ItemDelegate{
                text: "/r/popular"
                width: parent.width
                onClicked: {
                    showSubreddit(text);
                    subredditsDrawer.close();
                }
            }
        }

        delegate: ItemDelegate{
            id:subredditDelegate
            width: parent.width
            text: "/r/"+model.displayName
            onClicked: {
                showSubreddit(subredditDelegate.text);
                subredditsDrawer.close();
            }
        }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !subredditModel.busy && subredditModel.canLoadMore)
                subredditModel.refresh(true);
        }
    }

    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        section: SubredditModel.UserAsSubscriberSection
        onError: infoBanner.warning(errorString);

    }

    Connections {
        target: quickdditManager

        onSignedInChanged: {
            if (quickdditManager.isSignedIn) {
                subredditModel.refresh(false)
                //multiredditModel.refresh(false)
            } else {
                subredditModel.clear();
                //multiredditModel.clear();
            }
            signedIn=quickdditManager.isSignedIn;
        }
    }
}
