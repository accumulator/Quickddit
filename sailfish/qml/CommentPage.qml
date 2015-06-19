/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

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

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: commentPage
    title: "Comments"
    busy: commentModel.busy || commentVoteManager.busy || commentManager.busy || linkVoteManager.busy

    property alias link: commentModel.link
    property alias linkPermalink: commentModel.permalink
    property VoteManager linkVoteManager
    property bool morechildren_animation

    function refresh(refreshOlder) {
        morechildren_animation = false
        commentModel.refresh(refreshOlder);
    }

    readonly property variant commentSortModel: ["Best", "Top", "New", "Hot", "Controversial", "Old"]

    function __createCommentDialog(title, fullname, originalText, isEdit) {
        var dialog = pageStack.push(Qt.resolvedUrl("TextAreaDialog.qml"), {title: title, text: originalText || ""});
        dialog.accepted.connect(function() {
            if (isEdit) // edit
                commentManager.editComment(fullname, dialog.text);
            else // add
                commentManager.addComment(fullname, dialog.text);
        })
    }

    function loadMoreChildren(index, children) {
        morechildren_animation = true
        commentModel.moreComments(index, children);
    }

    SilicaListView {
        id: commentListView
        anchors.fill: parent
        model: commentModel

        PullDownMenu {
            MenuItem {
                enabled: !!link
                text: "Permalink"
                onClicked: globalUtils.createOpenLinkDialog(QMLUtils.toAbsoluteUrl(link.permalink));
            }
            MenuItem {
                text: "Sort"
                onClicked: globalUtils.createSelectionDialog("Sort", commentSortModel, commentModel.sort,
                function (selectedIndex) {
                    commentModel.sort = selectedIndex;
                    refresh(false);
                });
            }
            MenuItem {
                enabled: quickdditManager.isSignedIn && !commentManager.busy && !!link
                text: "Add comment"
                onClicked: __createCommentDialog("Add Comment", link.fullname);
            }
            MenuItem {
                enabled: !commentModel.busy
                text: "Refresh"
                onClicked: refresh(false);
            }
        }

        header: link ? headerComponent : null

        Component {
            id: headerComponent

            Column {
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

                        Bubble {
                            visible: link.flairText != ""
                            text: link.flairText
                        }

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

                            Text {
                                font.pixelSize: constant.fontSizeDefault
                                color: {
                                    if (link.likes > 0)
                                        return constant.colorLikes;
                                    else if (link.likes < 0)
                                        return constant.colorDislikes;
                                    else
                                        return constant.colorLight;
                                }
                                text: link.score + " points"
                            }

                            Text {
                                font.pixelSize: constant.fontSizeDefault
                                color: constant.colorLight
                                text: "·"
                            }

                            Text {
                                font.pixelSize: constant.fontSizeDefault
                                color: constant.colorLight
                                text: link.commentsCount + " comments"
                            }

                            Bubble {
                                color: "green"
                                visible: link.isSticky
                                text: "Sticky"
                            }

                            Bubble {
                                color: "red"
                                visible: link.isNSFW
                                text: "NSFW"
                            }

                            Bubble {
                                color: "green"
                                visible: link.isPromoted
                                text: "Promoted"
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
                        enabled: globalUtils.previewableImage(link.url)
                        onClicked: globalUtils.openImageViewPage(link.url);
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
                        text: "<style>a { color: " + Theme.highlightColor + "; }</style>" + link.text
                        onLinkActivated: globalUtils.openInTextLink(link);
                    }

                    // For spacing after text
                    Item { anchors { left: parent.left; right: parent.right } height: 1 }
                }

                Separator {
                    anchors { left: parent.left; right: parent.right }
                    color: constant.colorMid
                }

                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: visible ? viewAllCommentColumn.height + 2 * constant.paddingMedium : 0
                    visible: commentModel.commentPermalink

                    Column {
                        id: viewAllCommentColumn
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                        height: childrenRect.height

                        Label {
                            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                            wrapMode: Text.Wrap
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            text: "Viewing a single comment's thread"
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "View All Comments"
                            onClicked: {
                                commentModel.commentPermalink = false;
                                refresh(false);
                            }
                        }
                    }
                }
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
                dialog.editClicked.connect(function() {
                    __createCommentDialog("Edit Comment", model.fullname, model.rawBody, true);
                });
                dialog.deleteClicked.connect(function() {
                    commentDelegate.remorseAction("Deleting comment", function() {
                        commentManager.deleteComment(model.fullname);
                    })
                });
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
        onVoteSuccess: {
            if (fullname.indexOf("t1") === 0) // comment
                commentModel.changeLikes(fullname, likes);
            else if (fullname.indexOf("t3") === 0) // link
                commentModel.changeLinkLikes(fullname, likes);
        }
        onError: infoBanner.alert(errorString);
    }

    CommentManager {
        id: commentManager
        manager: quickdditManager
        model: commentModel
        linkAuthor: link ? link.author : ""
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.alert(errorString);
    }

    Connections {
        target: linkVoteManager
        onVoteSuccess: if (linkVoteManager != commentVoteManager) { commentModel.changeLinkLikes(fullname, likes); }
    }

    Component.onCompleted: {
        if (!linkVoteManager)
            linkVoteManager = commentVoteManager;
    }
}
