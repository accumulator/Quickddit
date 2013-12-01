import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: aboutSubredditPage

    property string subreddit

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: flickable
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: flickableColumn.height + 2 * constant.paddingMedium
        visible: !aboutSubredditManager.busy

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            Item {
                anchors { left: parent.left; right: parent.right }
                height: Math.max(headerImage.height, titleText.height)

                Image {
                    id: headerImage
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    source: aboutSubredditManager.headerImageUrl
                    asynchronous: true
                }

                Text {
                    id: titleText
                    anchors {
                        left: headerImage.right
                        leftMargin: headerImage.status == Image.Ready ? constant.paddingLarge : 0
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    elide: Text.ElideRight
                    font.pixelSize: constant.fontSizeLarge
                    color: constant.colorLight
                    font.bold: true
                    text: aboutSubredditManager.displayName
                }
            }

            Text {
                id: shortDescriptionText
                anchors { left: parent.left; right: parent.right }
                wrapMode: Text.Wrap
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorMid
                text: aboutSubredditManager.shortDescription
            }

            Text {
                id: userCountText
                anchors { left: parent.left; right: parent.right }
                wrapMode: Text.Wrap
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                text: aboutSubredditManager.subscribers + " subscribers | " +
                      aboutSubredditManager.activeUsers + " active users"
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorMid
            }

            Text {
                id: longDescriptionText
                anchors { left: parent.left; right: parent.right }
                wrapMode: Text.Wrap
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                text: aboutSubredditManager.longDescription
            }
        }
    }

    ScrollDecorator { flickableItem: flickable }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        busy: aboutSubredditManager.busy
        text: "About " + (aboutSubredditManager.url || "Subreddit")
        onClicked: flickable.contentY = 0;
    }

    AboutSubredditManager {
        id: aboutSubredditManager
        manager: quickdditManager
        onError: infoBanner.alert(errorString)
    }

    Component.onCompleted: aboutSubredditManager.refresh(aboutSubredditPage.subreddit);
}
