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

Item {
    id: commentDelegate
    property alias listItem: mainItem

    height: mainItem.height + (moreChildrenLoader.visible ? moreChildrenLoader.height: 0)
    Row {
        id:lineRow
        anchors{left: parent.left; top: parent.top; bottom: parent.bottom}
        Repeater {
            model: depth

            Item {
                anchors{top:parent.top; bottom: parent.bottom }
                width: 6
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: 2
                    color:{
                        var dk = ["#ed3146", "#ef9928", "#3eb34f", "#19b6ee", "#762572", "#e95420", "#cdcdcd", "#f99b0f", "#111111" ]
                        switch (index) {
                        case 0: case 1: case 2: case 3: case 4:
                                                        case 5: case 6: case 7: case 8:
                                                                                    return dk[index];
                                                                                default: return dk[9];
                        }
                    }
                }
            }
        }
    }

    SwipeDelegate{
        id:mainItem
        height: visible ? info.height+comment.height : 0
        anchors {left: lineRow.right; right: parent.right}
        visible: moreChildrenLoader.status == Loader.Null || model.view === "reply"
        swipe {enabled: true}
        onClicked: {
            if(model.isCollapsed)
                commentModel.expand(model.fullname)
            else
                commentModel.collapse(model.index)
        }
        Connections {
            target: commentsList

            onMovementStarted: mainItem.swipe.close()
        }

        leftPadding: 0
        topPadding: 0
        swipe.left: Row {
            anchors { top: parent.top;bottom: parent.bottom; left: parent.left }
            ActionButton {
                enabled: quickdditManager.isSignedIn && !commentVoteManager.busy && !model.isArchived && model.isValid
                ico: "../Icons/down.svg"
                color: model.likes===-1 ? Suru.color(Suru.Red,1) : Suru.foregroundColor

                onClicked: {
                    commentVoteManager.vote(model.fullname,model.likes===-1 ? VoteManager.Unvote : VoteManager.Downvote);
                    mainItem.swipe.close()
                }
            }

            ActionButton {
                visible: model.isAuthor && !model.isArchived
                ico: "../Icons/delete.svg"
                color: Suru.color(Suru.Red,1)

                onClicked: {
                    mainItem.swipe.close()
                    commentManager.deleteComment(model.fullname);
                }
            }
        }

        swipe.right: Row {
            anchors { top: parent.top;bottom: parent.bottom; right: parent.right }

            ActionButton {
                visible: model.isAuthor && !model.isArchived
                ico: "../Icons/edit.svg"
                color: Suru.foregroundColor

                onClicked: {
                    mainItem.swipe.close()
                    commentModel.setView(model.fullname, "edit");
                }
            }

            ActionButton {
                enabled: quickdditManager.isSignedIn && !model.isArchived && model.isValid && !link.isLocked
                ico: "../Icons/mail-reply.svg"
                color: Suru.foregroundColor

                onClicked: {
                    mainItem.swipe.close()
                    commentModel.setView(model.fullname, "reply");
                }
            }

            ActionButton {
                enabled: true
                ico: "../Icons/edit-copy.svg"
                color: Suru.foregroundColor

                onClicked: {
                    mainItem.swipe.close()
                    QMLUtils.copyToClipboard(model.rawBody);
                    infoBanner.alert("Comment coppied to clipboard")
                }
            }

            ActionButton {
                enabled: quickdditManager.isSignedIn && !commentSaveManager.busy
                ico: model.saved ? "../Icons/starred.svg" : "../Icons/non-starred.svg"
                color: Suru.foregroundColor

                onClicked: {
                    mainItem.swipe.close()
                    commentSaveManager.save(model.fullname,!model.saved)
                }
            }

            ActionButton {
                enabled: quickdditManager.isSignedIn && !commentVoteManager.busy && !model.isArchived && model.isValid
                ico: "../Icons/up.svg"
                color: model.likes===1 ? Suru.color(Suru.Green,1) : Suru.foregroundColor

                onClicked: {
                    mainItem.swipe.close()
                    commentVoteManager.vote(model.fullname,model.likes===1 ? VoteManager.Unvote : VoteManager.Upvote);
                }
            }
        }
        contentItem:Item{
            width: parent.width
            height: parent.height

            Label {
                id:info
                padding: 5

                color: Suru.foregroundColor
                linkColor: Suru.color(Suru.Orange,1)

                text:"<a href='"+model.author+"'>"+"u/" +model.author+(model.isSubmitter?" [submitter]":"")+"</a>"+ " ~ " + (model.score < 0 ? "-" : "") +  qsTr("%n points", "", Math.abs(model.score)) + " ~ "+ model.created

                onLinkActivated: {
                    pageStack.push(Qt.resolvedUrl("UserPage.qml"),{username:link.split(" ")[0]})
                }
            }

            Label {
                id:comment
                padding: 5

                color: Suru.foregroundColor
                linkColor: Suru.color(Suru.Orange,1)

                anchors {top: info.bottom;left: parent.left;right: parent.right}
                text: model.rawBody
                textFormat: Text.MarkdownText ? Text.MarkdownText : Text.StyledText

                wrapMode: "Wrap"
                onLinkActivated: globalUtils.openLink(link)
            }
        }
    }

    Loader {
        id: moreChildrenLoader
        anchors {
            left: lineRow.right;
            right: parent.right;
            top: (mainItem.visible ? mainItem.bottom : mainItem.top);
        }

        sourceComponent: model.isMoreChildren ? moreChildrenComponent
                                              : model.isCollapsed ? collapsedChildrenComponent
                                                                  : model.view !== "" ? editComponent
                                                                                      : undefined

        visible: sourceComponent != undefined

        Component {
            id: moreChildrenComponent

            Column {
                id: morechildrencolumn
                height: childrenRect.height


                Button {
                    id: loadMoreButton
                    text: model.moreChildrenCount > 0 ? qsTr("Load %n hidden comments", "", model.moreChildrenCount) : qsTr("Continue this thread");
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        if (model.moreChildrenCount > 0) {
                            commentPage.loadMoreChildren(model.index, model.moreChildren);
                        } else {
                            var clink = QMLUtils.toAbsoluteUrl("/r/" + link.subreddit + "/comments/" + link.fullname.substring(3) +
                                                               "//" + model.fullname.substring(3) + "?context=0")
                            globalUtils.openLink(clink);
                        }
                    }
                }
            }
        }

        Component {
            id: collapsedChildrenComponent

            Column {
                id: collapsedChildrenColumn
                height: childrenRect.height

                Button {
                    id: expandChildrenButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Show %n collapsed comments", "", model.moreChildrenCount);

                    onClicked: {
                        commentModel.expand(model.fullname);
                    }
                }
            }
        }

        Component {
            id: editComponent

            Column {
                id: editColumn
                height: model.view!=="" ? childrenRect.height : 0
                spacing: 1

                TextArea {
                    id: editTextArea
                    anchors { left: parent.left; right: parent.right }

                    wrapMode: TextEdit.WordWrap
                    placeholderText: model.view === "reply" ? qsTr("Enter your reply here...") : qsTr("Enter your new comment here...")
                    focus: true
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        id: acceptButton

                        text: model.view === "edit" ? qsTr("Save") : qsTr("Add")
                        enabled: !commentManager.busy

                        onClicked: {
                            if (model.view === "edit") {
                                commentManager.editComment(model.fullname, editTextArea.text);
                            } else if (model.view === "reply") {
                                commentManager.addComment(model.fullname, editTextArea.text);
                            } else if (model.view === "new") {
                                commentManager.addComment(link.fullname, editTextArea.text);
                            }
                        }
                    }

                    Button {
                        id: cancelButton
                        text: "Cancel"
                        visible: model.view !== "new"
                        onClicked: {
                            commentModel.setView(model.fullname, "");
                        }
                    }
                }

                Connections {
                    target: commentManager
                    onSuccess: if (fullname === model.fullname) {
                                   commentModel.setView(model.fullname, "")
                                   commentModel.setLocalData(model.fullname, undefined)
                               }
                }

                // save locally entered data when the delegate gets destroyed and restore when it returns in view
                Component.onDestruction: {
                    if (["reply","edit"].indexOf(model.view) >= 0) {
                        commentModel.setLocalData(model.fullname, editTextArea.text)
                    }
                }
                Component.onCompleted: {
                    if (["reply","edit"].indexOf(model.view) >= 0) {
                        editTextArea.text = (model.localData !== undefined) ? model.localData
                                                                            : model.view === "edit" ? model.rawBody : ""
                    }
                }
            }
        }
    }
}
