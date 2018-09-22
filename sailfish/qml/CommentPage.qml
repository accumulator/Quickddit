/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2018  Sander van Grieken

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
    title: qsTr("Comments")
    busy: (commentModel.busy && commentListView.count > 0) || commentVoteManager.busy || commentManager.busy || linkVoteManager.busy

    property alias link: commentModel.link
    property alias linkPermalink: commentModel.permalink
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager
    property bool morechildren_animation
    property bool widePage: commentPage.width > 700

    function refresh(refreshOlder) {
        morechildren_animation = false
        commentModel.refresh(refreshOlder);
    }

    readonly property variant commentSortModel: [qsTr("Best"), qsTr("Top"), qsTr("New"), qsTr("Hot"), qsTr("Controversial"), qsTr("Old")]

    function loadMoreChildren(index, children) {
        morechildren_animation = true
        commentModel.moreComments(index, children);
    }

    SilicaListView {
        id: commentListView
        anchors.fill: parent
        model: undefined

        PullDownMenu {
            MenuItem {
                visible: link.author === appSettings.redditUsername
                enabled: !link.isArchived
                text: qsTr("Edit Post")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SendLinkPage.qml"),
                                   { linkManager: linkManager,
                                     text: link.rawText || "",
                                     editPost: link.fullname,
                                     subreddit: link.subreddit,
                                     postTitle: link.title,
                                     postUrl: link.isSelfPost ? "" : link.url
                                   });
                }
            }

            MenuItem {
                text: qsTr("Sort")
                onClicked: globalUtils.createSelectionDialog(qsTr("Sort"), commentSortModel, commentModel.sort,
                function (selectedIndex) {
                    commentModel.sort = selectedIndex;
                    appSettings.commentSort = selectedIndex;
                    refresh(false);
                });
            }

            MenuItem {
                enabled: quickdditManager.isSignedIn && !commentManager.busy && !link.isArchived && !link.isLocked
                text: qsTr("Add comment")
                onClicked: {
                    commentModel.showNewComment();
                    commentListView.currentIndex = 0;
                    commentListView.positionViewAtIndex(0, ListView.Beginning);
                }
            }

            MenuItem {
                enabled: !commentModel.busy
                text: qsTr("Refresh")
                onClicked: refresh(false);
            }
        }

        header: link ? headerComponent : null

        Component {
            id: headerComponent

            Column {
                width: parent.width
                height: childrenRect.height

                QuickdditPageHeader { title: commentPage.title }

                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: (buttonItem.buttonsFitLeftOfThumb || !buttonItem.thumbOverflows)
                            ? Math.max(postInfoText.height + postButtonRow.height, constant.paddingMedium + thumbnail.height)
                            : Math.max(postInfoText.height, constant.paddingMedium + thumbnail.height + postButtonRow.height)

                    PostInfoText {
                        id: postInfoText
                        link: commentModel.link

                        anchors {
                            left: parent.left
                            right: thumbnail.left
                            margins: constant.paddingMedium
                        }
                    }

                    PostThumbnail {
                        id: thumbnail
                        link: commentModel.link
                        showLinkTypeIndicator: false

                        function scaleToText() {
                            var scale = (postInfoText.height + postButtonRow.height) / thumbnail.sourceSize.height;
                            return Math.max(Math.min(scale, 2.0), 1.0);
                        }

                        width: widePage ? sourceSize.width * scaleToText() : sourceSize.width
                        height: widePage ? sourceSize.height * scaleToText() : sourceSize.height

                        anchors {
                            right: parent.right
                            top: parent.top
                            margins: constant.paddingMedium
                        }
                    }

                    Item {
                        id: buttonItem
                        property bool thumbOverflows: thumbnail.height > postInfoText.height
                        property bool buttonsFitLeftOfThumb: postButtonRow.width < postInfoText.width

                        anchors.top: (buttonsFitLeftOfThumb || !thumbOverflows) ? postInfoText.bottom : thumbnail.bottom
                        anchors.left: parent.left
                        anchors.right: (thumbOverflows && buttonsFitLeftOfThumb) ? thumbnail.left : parent.right

                        PostButtonRow {
                            id: postButtonRow

                            anchors.horizontalCenter: parent.horizontalCenter

                            link: commentModel.link
                            linkVoteManager: commentPage.linkVoteManager
                            linkSaveManager: commentPage.linkSaveManager
                        }
                    }
                }

                Column {
                    id: bodyWrapper
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height
                    spacing: constant.paddingMedium
                    visible: link.text.length > 0

                    Separator {
                        anchors { left: parent.left; right: parent.right }
                        color: constant.colorMid
                    }

                    Flickable {
                        id: bodyText
                        anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                        height: bodyTextInner.height
                        contentWidth: bodyTextInner.paintedWidth
                        contentHeight: bodyTextInner.height
                        flickableDirection: Flickable.HorizontalFlick
                        interactive: bodyTextInner.paintedWidth > parent.width
                        clip: true

                        Text {
                            id: bodyTextInner
                            width: bodyWrapper.width - (constant.paddingMedium * 2)
                            wrapMode: Text.Wrap
                            textFormat: Text.RichText
                            font.pixelSize: constant.fontSizeDefault
                            color: constant.colorLight
                            text: constant.richtextStyle + link.text
                            onLinkActivated: globalUtils.openLink(link);
                        }
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
                        spacing: constant.paddingMedium

                        Label {
                            anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                            wrapMode: Text.Wrap
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Viewing a single comment's thread")
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("View All Comments")
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
            width: ListView.view.width
            menu: Component { CommentMenu {} }

            onClicked: {
                var p = {comment: model, post: link, commentVoteManager: commentVoteManager, commentSaveManager: commentSaveManager};
                var dialog = showMenu(p);
                dialog.showParent.connect(function() {
                    var parentIndex = commentModel.getParentIndex(index);
                    commentDelegate.ListView.view.positionViewAtIndex(parentIndex, ListView.Contain);
                    commentDelegate.ListView.view.currentIndex = parentIndex;
                    commentDelegate.ListView.view.currentItem.highlight();
                })
                dialog.replyClicked.connect(function() {
                    commentModel.setView(model.fullname, "reply");
                });
                dialog.editClicked.connect(function() {
                    commentModel.setView(model.fullname, "edit");
                });
                dialog.deleteClicked.connect(function() {
                    commentDelegate.remorseAction(qsTr("Deleting comment"), function() {
                        commentManager.deleteComment(model.fullname);
                    })
                });
            }
        }

        footer: LoadingFooter { visible: commentModel.busy && commentListView.count == 0; listViewItem: commentListView }

        VerticalScrollDecorator {}
    }

    Timer {
        // viewhack to delay having listview model until listview header is fully rendered,
        // otherwise the view stays fixed around a modelitem when header resizes,
        // pushing the top out and making the menu not immediately accessible.
        // (IMO a SilicaListView bug)
        // listview model is initialized to undefined, and is set from CommentModel signal handler below
        id: viewHack
        repeat: false; interval: 1
        onTriggered: commentListView.model = commentModel
    }

    CommentModel {
        id: commentModel
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.warning(errorString)
        onCommentLoaded: {
            var rlink = globalUtils.parseRedditLink(permalink)
            var post = rlink.path.split("/").pop()
            var postIndex = commentModel.getCommentIndex("t1_" + post);
            if (postIndex !== -1) {
                commentListView.model = commentModel
                commentListView.positionViewAtIndex(postIndex, ListView.Contain);
                commentListView.currentIndex = postIndex;
                commentListView.currentItem.highlight();
            } else {
                viewHack.start();
            }
        }
    }

    CommentManager {
        id: commentManager
        manager: quickdditManager
        model: commentModel
        linkAuthor: link ? link.author : ""
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.warning(errorString);
    }

    LinkManager {
        id: linkManager
        manager: quickdditManager
        commentModel: commentModel
        onSuccess: {
            infoBanner.alert(message);
            pageStack.pop();
        }
        onError: infoBanner.warning(errorString);
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
        onError: infoBanner.warning(errorString);
    }

    SaveManager {
        id: commentSaveManager
        manager: quickdditManager
        onSuccess: {
            if (fullname.indexOf("t1") === 0) // comment
                commentModel.changeSaved(fullname, saved);
            else if (fullname.indexOf("t3") === 0) // link
                commentModel.changeLinkSaved(fullname, saved);
        }
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

    Component.onCompleted: {
        // if we didn't get vote and save managers passed (for updating models in the calling page),
        // we use the local managers
        if (!linkVoteManager)
            linkVoteManager = commentVoteManager;
        if (!linkSaveManager)
            linkSaveManager = commentSaveManager;
    }
}
