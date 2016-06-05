/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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

    property alias link: commentModel.link
    property alias linkPermalink: commentModel.permalink
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager

    /*readonly*/ property variant commentSortModel: ["Best", "Top", "New", "Hot", "Controversial", "Old"]
    property Component __textAreaDialogComponent

    function __createCommentDialog(title, fullname, originalText, isEdit) {
        if (!__textAreaDialogComponent)
            __textAreaDialogComponent = Qt.createComponent("TextAreaDialog.qml");
        var dialog = __textAreaDialogComponent.createObject(commentPage, {title: title, text: originalText || ""});
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

    function __createLinkTextDialog(title, fullname, originalText) {
        if (!__textAreaDialogComponent)
            __textAreaDialogComponent = Qt.createComponent("TextAreaDialog.qml");
        var dialog = __textAreaDialogComponent.createObject(commentPage, {title: title, text: originalText || ""});
        dialog.statusChanged.connect(function() {
            if (dialog.status == DialogStatus.Closed) {
                dialog.destroy(250);
            }
        });
        dialog.accepted.connect(function() {
            linkManager.editLinkText(fullname, dialog.text);
        });
        dialog.open();
    }

    function loadMoreChildren(index, children) {
        commentModel.moreComments(index, children);
    }

    title: "Comments" + (link ? ": " + link.title : "")
    busy: commentModel.busy || commentVoteManager.busy || commentManager.busy || linkVoteManager.busy
    onHeaderClicked: commentListView.positionViewAtBeginning();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-add"
            enabled: quickdditManager.isSignedIn && !commentManager.busy && !!link && !link.isArchived
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
                text: "Edit Post"
                enabled: !link.isArchived
                visible: link.author === appSettings.redditUsername && link.isSelfPost
                onClicked: __createLinkTextDialog("Edit Post", link.fullname, link.rawText);
            }

            MenuItem {
                text: "Share"
                enabled: !!link
                onClicked: QMLUtils.shareUrl(QMLUtils.getRedditShortUrl(link.fullname), link.title);
            }
        }
    }

    ListView {
        id: commentListView

        property Item headerBodyWrapper: null

        anchors.fill: parent
        model: commentModel

        header: link ? headerComponent : null

        Component {
            id: headerComponent

            Column {
                width: commentListView.width
                height: childrenRect.height
                spacing: constant.paddingMedium

                // dummy item for top spacing
                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: 1
                }

                Row {
                    anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                    spacing: constant.paddingLarge

                    Bubble {
                        visible: link.flairText !== ""
                        text: link.flairText
                    }
                    Bubble {
                        color: "green"
                        visible: !!link.isSticky
                        text: "Sticky"
                        font.bold: true
                    }

                    Bubble {
                        color: "red"
                        visible: !!link.isNSFW
                        text: "NSFW"
                        font.bold: true
                    }

                    Bubble {
                        color: "green"
                        visible: !!link.isPromoted
                        text: "Promoted"
                        font.bold: true
                    }

                    Bubble {
                        visible: !!link.gilded
                        text: "Gilded"
                        color: "gold"
                        font.bold: true
                    }

                    Bubble {
                        visible: !!link.isArchived
                        text: "Archived"
                    }
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
                            textFormat: Text.RichText
                            text: "submitted " + link.created + " by " +
                                  "<a href=\"https://reddit.com/u/" + link.author.split(" ")[0] + "\">" + link.author + "</a>" +
                                  " to " + link.subreddit
                            onLinkActivated: globalUtils.openLink(link);
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
                        enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
                        checked: link.likes === 1
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
                        enabled: quickdditManager.isSignedIn && !linkVoteManager.busy && !link.isArchived
                        checked: link.likes === -1
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
                        enabled: globalUtils.previewableImage(link.url)
                                 || (globalUtils.redditLink(link.url) && !link.isSelfPost)
                        onClicked: {
                            if (globalUtils.previewableImage(link.url)) {
                                globalUtils.openImageViewPage(link.url);
                            } else if (globalUtils.redditLink(link.url)) {
                                globalUtils.openRedditLink(link.url);
                            }
                        }
                    }

                    Button {
                        iconSource: "image://theme/icon-l-browser-main-view"
                        onClicked: globalUtils.openNonPreviewLink(link.url, link.permalink);
                    }

                    Button {
                        iconSource: (link.saved
                                     ? "image://theme/icon-m-common-favorite-mark"
                                     : "image://theme/icon-m-common-favorite-unmark") +
                                    (theme.inverted ? "-inverse" : "")
                        onClicked: linkSaveManager.save(link.fullname, !link.saved);
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
                        onLinkActivated: globalUtils.openLink(link);
                    }

                    Component.onCompleted: commentListView.headerBodyWrapper = bodyWrapper;
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right }
                    height: 1
                    color: constant.colorMid
                }

                Column {
                    anchors { left: parent.left; right: parent.right }
                    visible: commentModel.commentPermalink
                    height: visible ? childrenRect.height : 0
                    spacing: constant.paddingMedium

                    Text {
                        anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                        wrapMode: Text.Wrap
                        font.pixelSize: constant.fontSizeMedium
                        font.bold: true
                        color: constant.colorLight
                        horizontalAlignment: Text.AlignHCenter
                        text: "Viewing a single comment's thread"
                    }

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "View All Comments"
                        onClicked: {
                            commentModel.commentPermalink = false;
                            commentModel.refresh(false);
                        }
                    }
                }
            }
        }

        delegate: CommentDelegate {
            id: commentDelegate
            menu: Component { CommentMenu {} }
            onClicked: {
                var p = {comment: model, linkPermalink: link.permalink, commentVoteManager: commentVoteManager, commentSaveManager: commentSaveManager};
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
    }

    ScrollDecorator { flickableItem: commentListView }

    CommentModel {
        id: commentModel
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.alert(errorString)
        onCommentLoaded: {
            if (link.text)
                 commentListView.headerBodyWrapper.visible = true;
            var path = permalink.split("?")[0].split("/");
            var post = path[path.length-1];
            var postIndex = commentModel.getCommentIndex("t1_" + post);
            if (postIndex !== -1) {
                commentListView.positionViewAtIndex(postIndex, ListView.Contain);
                commentListView.currentIndex = postIndex;
                commentListView.currentItem.highlight();
            } else {
                commentListView.positionViewAtBeginning();
            }
        }
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

    LinkManager {
        id: linkManager
        manager: quickdditManager
        commentModel: commentModel
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.alert(errorString);
    }

    SaveManager {
        id: commentSaveManager
        manager: quickdditManager
        onSuccess: link.saved = save;
        onError: infoBanner.warning(errorString);
    }

    Connections {
        target: linkVoteManager
        onVoteSuccess: if (linkVoteManager != commentVoteManager) { commentModel.changeLinkLikes(fullname, likes); }
    }

    Connections {
        target: linkSaveManager
        onSuccess: if (linkSaveManager != commentSaveManager) { commentModel.changeLinkSaved(fullname, saved); }
    }

    CommentManager {
        id: commentManager
        manager: quickdditManager
        model: commentModel
        linkAuthor: link ? link.author: ""
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.alert(errorString);
    }

    Component.onCompleted: {
        if (!linkVoteManager)
            linkVoteManager = commentVoteManager;
    }
}
