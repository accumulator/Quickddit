import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: commentPage

    property variant link
    property VoteManager linkVoteManager

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-callhistory" + (enabled ? "" : "-dimmed")
            enabled: !linkVoteManager.busy
            onClicked: dialogManager.createVoteDialog();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh" + (enabled ? "" : "-dimmed")
            enabled: !commentModel.busy
            onClicked: commentModel.refresh(false);
        }
        ToolIcon {
            platformIconId: enabled ? "toolbar-gallery" : "toolbar-gallery-dimmed"
            enabled: {
                if (!link) return false;
                if (link.domain == "i.imgur.com" || link.domain == "imgur.com")
                    return true;
                if (/^https?:\/\/.+\.(jpe?g|png|gif)/i.test(link.url))
                    return true;
                else
                    return false;
            }
            onClicked: {
                var p = {};
                if (link.domain == "imgur.com")
                    p.imgurUrl = link.url;
                else
                    p.imageUrl = link.url;
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), p);
            }
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
                text: "Sort"
                onClicked: dialogManager.createCommentSortDialog();
            }
            MenuItem {
                text: "Share"
                onClicked: QMLUtils.shareUrl(QMLUtils.getRedditShortUrl(link.fullname), link.title);
            }
            MenuItem {
                text: "URL"
                onClicked: globalDialogManager.createOpenLinkDialog(commentPage, link.url);
            }

            MenuItem {
                text: "Permalink"
                onClicked: globalDialogManager.createOpenLinkDialog(commentPage,
                                                                    QMLUtils.getRedditFullUrl(link.permalink));
            }
        }
    }

    ListView {
        id: commentListView
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: commentModel
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

                        CustomCountBubble {
                            value: link.score
                            colorMode: link.likes
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: constant.fontSizeDefault
                            color: constant.colorLight
                            text: "points"
                        }

                        CustomCountBubble {
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
                    textFormat: Text.RichText
                    font.pixelSize: constant.fontSizeDefault
                    color: constant.colorLight
                    text: link.text
                    onLinkActivated: {
                        infoBanner.alert("Launching web browser...");
                        Qt.openUrlExternally(link);
                    }
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorMid
            }
        }
    }

    ScrollDecorator { flickableItem: commentListView }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "Comments: " + link.title
        busy: commentModel.busy || commentVoteManager.busy || linkVoteManager.busy
        onClicked: commentListView.positionViewAtBeginning()
    }

    CommentModel {
        id: commentModel
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.alert(errorString)
    }

    VoteManager {
        id: commentVoteManager
        manager: quickdditManager
        type: VoteManager.Comment
        model: commentModel
        onError: infoBanner.alert(errorString);
    }

    QtObject {
        id: dialogManager

        property Component __voteDialogComponent: null
        property Component __commentSortDialogComponent: null
        property Component __commentDialogComponent: null

        function createVoteDialog() {
            if (!__voteDialogComponent)
                __voteDialogComponent = Qt.createComponent("LinkDialog.qml");
            var p = { link: link, linkVoteManager: linkVoteManager, voteOnly: true }
            var dialog = __voteDialogComponent.createObject(commentPage, p);
            if (!dialog)
                console.log("Error creating dialog:" + __voteDialogComponent.errorString());
        }

        function createCommentSortDialog() {
            if (!__commentSortDialogComponent)
                __commentSortDialogComponent = Qt.createComponent("CommentSortDialog.qml");
            var p = { selectedIndex: commentModel.sort }
            var dialog = __commentSortDialogComponent.createObject(commentPage, p);
            if (!dialog) {
                console.log("Error creating dialog:" + __commentSortDialogComponent.errorString());
                return;
            }
            dialog.accepted.connect(function () {
                commentModel.sort = dialog.selectedIndex;
                commentModel.refresh(false);
            })
        }

        function createCommentDialog(comment, index) {
            if (!__commentDialogComponent)
                __commentDialogComponent = Qt.createComponent("CommentDialog.qml");
            var p = { comment: comment, linkPermalink: link.permalink, commentVoteManager: commentVoteManager }
            var dialog = __commentDialogComponent.createObject(commentPage, p);
            if (!dialog) {
                console.log("Error creating dialog:" + __commentDialogComponent.errorString());
                return;
            }
            dialog.positionToParent.connect(function() {
                var parentIndex = commentModel.getParentIndex(index);
                commentListView.positionViewAtIndex(parentIndex, ListView.Beginning);
            })
        }
    }

    Component.onCompleted: commentModel.refresh(false);
}
