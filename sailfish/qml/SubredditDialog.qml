import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

Dialog {
    id: subredditDialog

    property SubredditModel subredditModel
    property alias text: subredditTextField.text

    property bool busy: subredditModel.busy

    acceptDestinationAction: PageStackAction.Replace

    Item {
        anchors.fill: parent

        DialogHeader {
            id: dialogHeader
            anchors { left: parent.left; right: parent.right; top: parent.top }
            dialog: subredditDialog
            title: "Subreddits"
        }

        TextField {
            id: subredditTextField
            anchors {
                left: parent.left; right: parent.right
                top: dialogHeader.bottom
            }
            placeholderText: "Go to specific subreddit..."
        }

        Column {
            id: mainOptionColumn
            anchors { left: parent.left; right: parent.right; top: subredditTextField.bottom }
            height: childrenRect.height

            Repeater {
                id: mainOptionRepeater
                anchors { left: parent.left; right: parent.right }
                model: ["Front", "All", "Browse for Subreddits..."]

                ListItem {
                    contentHeight: Theme.itemSizeSmall
                    width: mainOptionRepeater.width

                    Text {
                        id: subredditText
                        anchors {
                            left: parent.left; right: parent.right; margins: constant.paddingLarge
                            verticalCenter: parent.verticalCenter
                        }
                        font.pixelSize: constant.fontSizeMedium
                        color: constant.colorLight
                        text: modelData
                    }

                    onClicked: {
                        switch (index) {
                        case 0: subredditTextField.text = ""; break;
                        case 1: subredditTextField.text = "all"; break;
                        case 2: acceptDestination = Qt.resolvedUrl("SubredditsBrowsePage.qml"); break;
                        }
                        subredditDialog.accept();
                    }
                }
            }
        }

        SectionHeader {
            id: subscribedSubredditHeader
            anchors.top: mainOptionColumn.bottom
            text: "Subscribed Subreddit"
        }

        ListView {
            id: subscribedSubredditListView
            anchors {
                top: subscribedSubredditHeader.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }
            visible: subredditModel ? true : false
            clip: true
            model: visible ? subredditModel : 0
            delegate: ListItem {
                contentHeight: Theme.itemSizeSmall

                Text {
                    id: subscribedSubredditText
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: model.url
                }

                onClicked: {
                    subredditTextField.text = model.displayName;
                    subredditDialog.accept();
                }
            }

            VerticalScrollDecorator {}
        }
    }
}
