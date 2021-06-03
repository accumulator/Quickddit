/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import quickddit.Core 1.0
import QtQuick.Controls.Suru 2.2
import "../"
import "../Delegates"

Page {
    id:commentPage
    title:link.title

    property alias link: commentModel.link
    property alias linkPermalink: commentModel.permalink
    signal downloadImage
    property bool previeableImage: false

    function loadMoreChildren(index, children) {
        commentModel.moreComments(index, children);
    }

    function getButtons(){
        return toolButtons
    }

    function onItemClicked(i) {
        switch(i) {
        case 0: commentModel.sort = CommentModel.UndefinedSort; break;
        case 1: commentModel.sort = CommentModel.TopSort; break;
        case 2: commentModel.sort = CommentModel.NewSort; break;
        case 3: commentModel.sort = CommentModel.HotSort; break;
        case 4: commentModel.sort = CommentModel.ControversialSort; break;
        case 5: commentModel.sort = CommentModel.OldSort; break;
        }
        appSettings.commentSort = commentModel.sort
        commentModel.refresh(false)
    }

    Component {
        id: toolButtons
        Row {
            ActionButton {
                id:downloadBtn
                ico: "qrc:/Icons/save.svg"
                size: Suru.units.gu(3)
                color: Suru.color(Suru.White,1)
                visible: previeableImage
                onClicked: downloadImage()
            }

            ActionButton {
                id:sort
                ico: "qrc:/Icons/filters.svg"
                size: Suru.units.gu(3)
                color: Suru.color(Suru.White,1)
                onClicked: sortMenu.open()
                Menu {
                    id: sortMenu
                    y:parent.y+parent.height
                    MenuItem {
                        text: qsTr("Best")
                        onClicked: onItemClicked(0)
                    }
                    MenuItem {
                        text: qsTr("Top")
                        onClicked: onItemClicked(1)
                    }
                    MenuItem {
                        text: qsTr("New")
                        onClicked: onItemClicked(2)
                    }
                    MenuItem {
                        text: qsTr("Hot")
                        onClicked: onItemClicked(3)
                    }
                    MenuItem {
                        text: qsTr("Controversial")
                        onClicked: onItemClicked(4)
                    }
                    MenuItem {
                        text: qsTr("Old")
                        onClicked: onItemClicked(5)
                    }
                }
            }
            ActionButton {
                id:del
                ico: "qrc:/Icons/delete.svg"
                size: Suru.units.gu(3)
                color: Suru.color(Suru.White,1)
                visible: link.author === appSettings.redditUsername
                enabled: !link.isArchived
                onClicked: {
                    //TODO: make confirmation dialog
                    linkManager.deleteLink(link.fullname);
                    pageStack.pop();
                }
            }
            ActionButton {
                id:edit
                ico: "qrc:/Icons/edit.svg"
                size: Suru.units.gu(3)
                color: Suru.color(Suru.White,1)
                visible: link.author === appSettings.redditUsername
                enabled: !link.isArchived
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/SendLinkPage.qml"),
                                   { linkManager: linkManager,
                                       text: link.rawText || "",
                                       editPost: link.fullname,
                                       subreddit: link.subreddit,
                                       postTitle: link.title,
                                       postUrl: link.isSelfPost ? "" : link.url
                                   });
                }
            }

            ActionButton {
                id:newPost
                ico: "qrc:/Icons/add.svg"
                size: Suru.units.gu(3)
                color: Suru.color(Suru.White,1)
                visible: quickdditManager.isSignedIn
                enabled: !commentManager.busy && !link.isArchived && !link.isLocked
                onClicked: {
                    commentModel.showNewComment();
                    commentsList.currentIndex = 0;
                    commentsList.positionViewAtIndex(0, ListView.Beginning);
                }
            }
        }
    }

    Component {
        id:linkDelegateComponent
        LinkDelegate {
            id:linkDelegate
            width: commentsList.width
            link: commentPage.link
            compact: false
            linkVoteManager: commentVoteManager
            linkSaveManager: commentSaveManager

            Connections {
                target: commentPage
                onDownloadImage: {
                    QMLUtils.saveImage(linkDelegate.imageUrl)
                }
            }
            Binding {
                target: commentPage
                property: "previeableImage"
                value: linkDelegate.previewableImage
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: !link
        visible: running
    }

    ListView {
        id:commentsList
        anchors.fill: parent

        header: Loader {
            sourceComponent: commentModel.link && !commentModel.busy ? linkDelegateComponent : null
            onLoaded: {
                commentsList.contentY = commentsList.originY
                sourceComponent = sourceComponent
            }
        }

        model: commentModel
        delegate: CommentDelegate {
            id:commentDelegate
            width: commentsList.width
        }
        footer: Item {
            width: parent.width
            height: 400
        }
    }

    CommentModel {
        id: commentModel
        manager: quickdditManager
        permalink: link.permalink
        onError: infoBanner.alert(errorString)

        onCommentLoaded: {
            var rlink = globalUtils.parseRedditLink(permalink)
            var post = rlink.path.split("/").pop()
            var postIndex = commentModel.getCommentIndex("t1_" + post);
            if (postIndex !== -1) {
                commentListView.model = commentModel
                commentListView.positionViewAtIndex(postIndex, ListView.Contain);
                commentListView.currentIndex = postIndex;
                commentListView.currentItem.highlight();
            }
        }
    }

    Connections {
        target: QMLUtils
        onSaveImageSucceeded: {
            infoBanner.alert("Image saved to " + name);
        }

        onSaveImageFailed: {
            infoBanner.alert("Image already saved");
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
}
