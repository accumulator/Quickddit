import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

AbstractPage {
    id: mainPage
    objectName: "mainPage"
    title: linkModel.title
    busy: linkModel.busy || linkVoteManager.busy

    readonly property variant sectionModel: ["Hot", "New", "Rising", "Controversial", "Top"]

    function refresh(subreddit) {
        if (subreddit !== undefined)
            linkModel.subreddit = subreddit;
        linkModel.refresh(false);
    }

    property Component __subredditDialogModelComponent: Component {
        SubredditModel {
            manager: quickdditManager
            section: SubredditModel.UserAsSubscriberSection
            onError: infoBanner.alert(errorString);
        }
    }
    property QtObject __subredditDialogModel

    SilicaListView {
        id: linkListView
        anchors.fill: parent
        model: linkModel

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("AppSettingsPage.qml"))
            }
            MenuItem {
                text: "Search"
                onClicked: pageStack.push(Qt.resolvedUrl("SearchDialog.qml"));
            }
            MenuItem {
                text: "Subreddits"
                onClicked: {
                    var p = {}
                    if (quickdditManager.isSignedIn) {
                        if (!__subredditDialogModel)
                            __subredditDialogModel = __subredditDialogModelComponent.createObject(mainPage);
                        p.subredditModel = __subredditDialogModel;
                    }
                    var dialog = pageStack.push(Qt.resolvedUrl("SubredditDialog.qml"), p);
                    dialog.accepted.connect(function() {
                        if (!dialog.acceptDestination) {
                            linkModel.subreddit = dialog.text;
                            linkModel.refresh(false);
                        }
                    })
                }
            }
            MenuItem {
                text: "About /r/" + linkModel.subreddit
                visible: linkModel.subreddit != "" && linkModel.subreddit.toLowerCase() != "all"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutSubredditPage.qml"), {subreddit: linkModel.subreddit});
                }
            }
            MenuItem {
                text: "Section"
                onClicked: {
                    globalUtils.createSelectionDialog("Section", sectionModel, linkModel.section,
                    function(selectedIndex) {
                        linkModel.section = selectedIndex;
                        linkModel.refresh(false);
                    });
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: linkModel.refresh(false);
            }
        }

        header: PageHeader { title: mainPage.title }

        delegate: LinkDelegate {
            menu: Component { LinkMenu {} }
            showMenuOnPressAndHold: false
            showSubreddit: linkModel.subreddit == ""
                           || linkModel.subreddit.toLowerCase() == "all"
            onClicked: {
                var p = { link: model, linkVoteManager: linkVoteManager };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
            onPressAndHold: showMenu({link: model, linkVoteManager: linkVoteManager});
        }

        PushUpMenu {
            MenuItem {
                text: "Load more"
                enabled: !linkModel.busy
                onClicked: linkModel.refresh(true);
            }
        }

        ViewPlaceholder { enabled: linkListView.count == 0 && !linkModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    LinkModel {
        id: linkModel
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    VoteManager {
        id: linkVoteManager
        manager: quickdditManager
        type: VoteManager.Link
        model: linkModel
        onError: infoBanner.alert(errorString);
    }
}
