import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import Quickddit 1.0

Page {
    id: commentPage

    property variant link

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: dialogManager.createCommentSortDialog();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: commentManager.refresh();
        }
        ToolIcon {
            platformIconId: enabled ? "toolbar-gallery" : "toolbar-gallery-dimmed"
            enabled: {
                // TODO: allow other image url that ends with ".jpg/png/gif"
                // TODO: parse "imgur.com" domain to its image url
                // TODO: parse Imgur album
                if (!link) return false;
                if (link.domain == "i.imgur.com")
                    return true;
                else
                    return false;
            }
            onClicked: pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imageUrl: link.url});
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: menu.open();
        }
    }

    Menu {
        id: menu

        MenuLayout {
            MenuItem {
                text: "URL"
                onClicked: globalDialogManager.createOpenLinkDialog(commentPage, link.url);
            }

            MenuItem {
                text: "Comment Permalink"
                onClicked: globalDialogManager.createOpenLinkDialog(commentPage,
                                                                    "http://www.reddit.com" + link.permalink);
            }
        }
    }

    ListView {
        id: commentListView
        anchors {
            top: pageHeader.bottom; topMargin: constant.paddingMedium
            left: parent.left; right: parent.right; bottom: parent.bottom
        }
        model: commentManager.model
        delegate: CommentDelegate {}
        // TODO: Fix header bug
        header: Column {
            width: ListView.view.width
            height: childrenRect.height
            spacing: constant.paddingMedium

            Item {
                id: titleWrapper
                anchors { left: parent.left; right: parent.right }
                height: Math.max(titleColumn.height, thumbnail.height)

                Column {
                    id: titleColumn
                    anchors {
                        left: parent.left
                        right: thumbnail.left
                        margins: constant.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    height: childrenRect.height
                    spacing: constant.paddingMedium

                    Text {
                        id: titleText
                        anchors { left: parent.left; right: parent.right }
                        wrapMode: Text.Wrap
                        font.pixelSize: constant.fontSizeDefault
                        color: constant.colorLight
                        font.bold: true
                        text: link.title + " (" + link.domain + ")"
                    }

                    Text {
                        id: timeAndAuthorText
                        anchors { left: parent.left; right: parent.right }
                        wrapMode: Text.Wrap
                        font.pixelSize: constant.fontSizeDefault
                        color: constant.colorMid
                        text: "submitted " + link.created + " by " + link.author +
                              " to " + link.subreddit
                    }

                    Row {
                        anchors { left: parent.left; right: parent.right }
                        spacing: constant.paddingMedium

                        CountBubble {
                            largeSized: true
                            value: link.score
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: constant.fontSizeDefault
                            color: constant.colorLight
                            text: "points"
                        }

                        CountBubble {
                            largeSized: true
                            value: link.commentsCount
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: constant.fontSizeDefault
                            color: constant.colorLight
                            text: "comments"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: constant.fontSizeDefault
                            color: "green"
                            visible: link.isSticky
                            text: "Sticky"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: constant.fontSizeDefault
                            color: "red"
                            visible: link.isNSFW
                            text: "NSFW"
                        }
                    }
                }

                Image {
                    id: thumbnail
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: constant.paddingMedium
                    }
                    source: link.thumbnailUrl
                    asynchronous: true
                }
            }

            Column {
                id: bodyWrapper
                anchors { left: parent.left; right: parent.right }
                height: childrenRect.height
                spacing: constant.paddingMedium
                visible: link.text != ""

                Rectangle {
                    anchors { left: parent.left; right: parent.right }
                    height: 1
                    color: constant.colorMid
                }

                Text {
                    id: bodyText
                    anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                    wrapMode: Text.Wrap
                    font.pixelSize: constant.fontSizeDefault
                    color: constant.colorLight
                    text: link.text
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorMid
            }
        }

        EmptyContentLabel { visible: commentListView.count == 0 && !commentManager.busy }
    }

    ScrollDecorator { flickableItem: commentListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "Comments: " + link.title
        busy: commentManager.busy
        onClicked: commentListView.positionViewAtBeginning()
    }

    CommentManager {
        id: commentManager
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.alert(errorString)
    }

    QtObject {
        id: dialogManager

        property Component __commentSortDialogComponent: null

        function createCommentSortDialog() {
            if (!__commentSortDialogComponent)
                __commentSortDialogComponent = Qt.createComponent("CommentSortDialog.qml");
            var dialog = __commentSortDialogComponent.createObject(commentPage);
            if (!dialog) {
                console.log("Error creating dialog:" + __commentSortDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function () {
                commentManager.sort = dialog.selectedIndex;
                commentManager.refresh();
            })
        }
    }

    Component.onCompleted: commentManager.refresh();
}
