import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

AbstractPage {
    id: commentPage
    title: "Comments"
    busy: commentModel.busy || commentVoteManager.busy || commentManager.busy || linkVoteManager.busy

    property variant link
    property VoteManager linkVoteManager

    readonly property variant commentSortModel: ["Best", "Top", "New", "Hot", "Controversial", "Old"]

    function __createCommentDialog(titleText, replyToFullname) {
        var dialog = pageStack.push(Qt.resolvedUrl("TextAreaDialog.qml"), {titleText: titleText});
        dialog.accepted.connect(function() {
            commentManager.addComment(replyToFullname, dialog.text);
        })
    }

    SilicaListView {
        id: commentListView
        anchors.fill: parent
        model: commentModel

        PullDownMenu {
            MenuItem {
                text: "Permalink"
                onClicked: globalUtils.createOpenLinkDialog(QMLUtils.toAbsoluteUrl(link.permalink));
            }
            MenuItem {
                text: "Sort"
                onClicked: globalUtils.createSelectionDialog("Sort", commentSortModel, commentModel.sort,
                function (selectedIndex) {
                    commentModel.sort = selectedIndex;
                    commentModel.refresh(false);
                });
            }
            MenuItem {
                text: "Add comment"
                onClicked: __createCommentDialog("Add Comment", link.fullname);
            }
            MenuItem {
                text: "Refresh"
                onClicked: commentModel.refresh(false);
            }
        }

        header: Column {
            width: parent.width
            height: childrenRect.height

            PageHeader { title: commentPage.title }

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

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                height: Theme.iconSizeLarge
                spacing: constant.paddingLarge

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon.height: Theme.iconSizeLarge - constant.paddingMedium
                    icon.width: Theme.iconSizeLarge - constant.paddingMedium
                    icon.source: "image://theme/icon-l-up"
                    enabled: quickdditManager.isSignedIn && !linkVoteManager.busy
                    highlighted: link.likes == 1
                    onClicked: {
                        if (highlighted)
                            linkVoteManager.vote(link.fullname, VoteManager.Unvote)
                        else
                            linkVoteManager.vote(link.fullname, VoteManager.Upvote)
                    }
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon.height: Theme.iconSizeLarge - constant.paddingMedium
                    icon.width: Theme.iconSizeLarge - constant.paddingMedium
                    icon.source: "image://theme/icon-l-down"
                    enabled: quickdditManager.isSignedIn && !linkVoteManager.busy
                    highlighted: link.likes == -1
                    onClicked: {
                        if (highlighted)
                            linkVoteManager.vote(link.fullname, VoteManager.Unvote)
                        else
                            linkVoteManager.vote(link.fullname, VoteManager.Downvote)
                    }
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon.height: Theme.iconSizeLarge - constant.paddingMedium
                    icon.width: Theme.iconSizeLarge - constant.paddingMedium
                    icon.source: "image://theme/icon-l-image"
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

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon.height: Theme.iconSizeLarge - constant.paddingLarge
                    icon.width: Theme.iconSizeLarge - constant.paddingLarge
                    icon.source: "image://theme/icon-lock-social"
                    onClicked: globalUtils.createOpenLinkDialog(link.url);
                }
            }

            Column {
                id: bodyWrapper
                anchors { left: parent.left; right: parent.right }
                height: childrenRect.height
                spacing: constant.paddingMedium
                visible: bodyText.text.length > 0

                Separator {
                    anchors { left: parent.left; right: parent.right }
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
                    onLinkActivated: globalUtils.openInTextLink(link);
                }

                // For spacing after text
                Item { anchors { left: parent.left; right: parent.right } height: 1 }
            }

            Separator {
                anchors { left: parent.left; right: parent.right }
                color: constant.colorMid
            }
        }

        delegate: CommentDelegate {
            id: commentDelegate
            menu: Component { CommentMenu {} }
            onClicked: {
                var p = {comment: model, linkPermalink: link.permalink, commentVoteManager: commentVoteManager};
                var dialog = showMenu(p);
                dialog.showParent.connect(function() {
                    var parentIndex = commentModel.getParentIndex(index);
                    commentDelegate.ListView.view.positionViewAtIndex(parentIndex, ListView.Contain);
                    commentDelegate.ListView.view.currentIndex = parentIndex;
                    commentDelegate.ListView.view.currentItem.highlight();
                })
                dialog.replyClicked.connect(function() { __createCommentDialog("Reply Comment", model.fullname); });
            }
        }

        VerticalScrollDecorator {}
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

    CommentManager {
        id: commentManager
        manager: quickdditManager
        model: commentModel
        onError: infoBanner.alert(errorString);
    }
}
