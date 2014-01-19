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

import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit.Core 1.0

AbstractPage {
    id: commentPage

    property variant link
    property VoteManager linkVoteManager

    /*readonly*/ property variant commentSortModel: ["Best", "Top", "New", "Hot", "Controversial", "Old"]
    property Component __textAreaDialogComponent

    function __createCommentDialog(titleText, fullname, originalText, isEdit) {
        if (!__textAreaDialogComponent)
            __textAreaDialogComponent = Qt.createComponent("TextAreaDialog.qml");
        var dialog = __textAreaDialogComponent.createObject(commentPage, {titleText: titleText, text: originalText || ""});
        dialog.statusChanged.connect(function() {
            if (dialog.status == DialogStatus.Closed) {
                dialog.destroy(250);
            }
        });
        dialog.accepted.connect(function() {
            if (isEdit) // edit
                commentManager.editComment(fullname, dialog.text);
            else // add
                commentManager.addComment(fullname, dialog.text);
        });
        dialog.open();
    }

    title: "Comments: " + link.title
    busy: commentModel.busy || commentVoteManager.busy || commentManager.busy || linkVoteManager.busy
    onHeaderClicked: commentListView.positionViewAtBeginning();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-add"
            enabled: quickdditManager.isSignedIn && !commentManager.busy
            opacity: enabled ? 1 : 0.25
            onClicked: __createCommentDialog("Add Comment", link.fullname);
        }
        ToolIcon {
            platformIconId: "toolbar-list"
            onClicked: {
                globalUtils.createSelectionDialog("Sort", commentSortModel, commentModel.sort,
                function (selectedIndex) {
                    commentModel.sort = selectedIndex;
                    commentModel.refresh(false);
                })
            }
        }
        ToolIcon {
            platformIconId: "toolbar-refresh" + (enabled ? "" : "-dimmed")
            enabled: !commentModel.busy
            onClicked: commentModel.refresh(false);
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
                text: "Share"
                onClicked: QMLUtils.shareUrl(QMLUtils.getRedditShortUrl(link.fullname), link.title);
            }
            MenuItem {
                text: "Permalink"
                onClicked: globalUtils.createOpenLinkDialog(QMLUtils.toAbsoluteUrl(link.permalink));
            }
        }
    }

    ListView {
        id: commentListView

        property Item headerBodyWrapper: null

        anchors.fill: parent
        model: commentModel
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
                dialog.replyClicked.connect(function() { __createCommentDialog("Reply Comment", model.fullname) })
                dialog.editClicked.connect(function() {
                    __createCommentDialog("Edit Comment", model.fullname, model.rawBody, true);
                })
                dialog.deleteClicked.connect(function() {
                    globalUtils.createQueryDialog("Delete Comment", "Are you sure want to delete this comment?",
                    function() { commentManager.deleteComment(model.fullname); });
                });
            }
        }
        header: Column {
            width: ListView.view.width
            height: childrenRect.height
            spacing: constant.paddingMedium

            // dummy item for top spacing
            Item {
                anchors { left: parent.left; right: parent.right }
                height: 1
            }

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

            ButtonRow {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                exclusive: false

                Button {
                    iconSource: "image://theme/icon-m-toolbar-up" + (enabled ? "" : "-dimmed")
                                + (appSettings.whiteTheme ? "" : "-white")
                    enabled: quickdditManager.isSignedIn && !linkVoteManager.busy
                    checked: link.likes == 1
                    onClicked: {
                        if (checked)
                            linkVoteManager.vote(link.fullname, VoteManager.Unvote)
                        else
                            linkVoteManager.vote(link.fullname, VoteManager.Upvote)
                    }
                }

                Button {
                    iconSource: "image://theme/icon-m-toolbar-down" + (enabled ? "" : "-dimmed")
                                + (appSettings.whiteTheme ? "" : "-white")
                    enabled: quickdditManager.isSignedIn && !linkVoteManager.busy
                    checked: link.likes == -1
                    onClicked: {
                        if (checked)
                            linkVoteManager.vote(link.fullname, VoteManager.Unvote)
                        else
                            linkVoteManager.vote(link.fullname, VoteManager.Downvote)
                    }
                }

                Button {
                    iconSource: "image://theme/icon-m-toolbar-gallery" + (enabled ? "" : "-dimmed")
                                + (appSettings.whiteTheme ? "" : "-white")
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

                Button {
                    iconSource: "image://theme/icon-l-browser-main-view"
                    onClicked: globalUtils.createOpenLinkDialog(link.url);
                }
            }

            Column {
                id: bodyWrapper
                anchors { left: parent.left; right: parent.right }
                height: visible ? childrenRect.height : 0
                spacing: constant.paddingMedium
                visible: false

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
                    onLinkActivated: globalUtils.openInTextLink(link);
                }

                Component.onCompleted: commentListView.headerBodyWrapper = bodyWrapper;
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: 1
                color: constant.colorMid
            }
        }
    }

    ScrollDecorator { flickableItem: commentListView }

    CommentModel {
        id: commentModel
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.alert(errorString)
        onCommentLoaded: {
            if (link.text) {
                commentListView.headerBodyWrapper.visible = true;
                commentListView.positionViewAtBeginning();
            }
        }
    }

    VoteManager {
        id: commentVoteManager
        manager: quickdditManager
        onVoteSuccess: commentModel.changeLikes(fullname, likes);
        onError: infoBanner.alert(errorString);
    }

    CommentManager {
        id: commentManager
        manager: quickdditManager
        model: commentModel
        linkAuthor: link.author
        onError: infoBanner.alert(errorString);
    }
}
