/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2017  Sander van Grieken

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

import QtQuick 2.6
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

Item {
    id: commentDelegate

    property alias menu: mainItem.menu
    signal clicked

    function showMenu(properties) {
        return mainItem.showMenu(properties);
    }

    function highlight() {
        highlightAnimation.start();
    }

    function remorseAction(title, action, timeout) {
        mainItem.remorseAction(title, action, timeout);
    }

    height: (moreChildrenLoader.status == Loader.Null || model.view === "reply" ? mainItem.height : 0)
            + (moreChildrenLoader.visible ? constant.paddingMedium + moreChildrenLoader.height : 0)

    ListView.onAdd: ParallelAnimation {
        NumberAnimation {
            target: commentDelegate
            properties: "opacity"
            from: 0; to: 1
            duration: commentPage.morechildren_animation ? 500 : 100
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: commentDelegate
            properties: "x"
            from: commentDelegate.x + commentDelegate.width * 0.5; to: commentDelegate.x
            duration: commentPage.morechildren_animation ? 400 : 0
            easing.type: Easing.InOutQuad
        }
    }

    ListView.onRemove: RemoveAnimation {
        target: commentDelegate
        duration: (commentPage.morechildren_animation && !(model.isMoreChildren || model.isCollapsed)) ? 400 : 0
    }

    Row {
        id: lineRow
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }

        Repeater {
            model: depth

            Item {
                anchors { top: parent.top; bottom: parent.bottom }
                width: constant.commentRepliesIndentWidth

                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: Math.floor(2 * QMLUtils.pScale)
                    color: {
                        switch (index) {
                        case 0: case 1: case 2: case 3: case 4:
                        case 5: case 6: case 7: case 8:
                            return constant.commentRepliesColor[index];
                        default: return constant.commentRepliesColor[9];
                        }
                    }
                }
            }
        }
    }

    ListItem {
        id: mainItem
        anchors { left: lineRow.right; right: parent.right }
        contentHeight: mainColumn.height + 2 * constant.paddingMedium
        showMenuOnPressAndHold: false
        visible: moreChildrenLoader.status == Loader.Null || model.view === "reply"

        onPressAndHold: {
            commentPage.morechildren_animation = true;
            commentModel.collapse(index)
        }

        Rectangle {
            id: highlightRect
            anchors.fill: parent
            color: "transparent"

            SequentialAnimation {
                id: highlightAnimation

                ColorAnimation {
                    target: highlightRect; property: "color"
                    to: Theme.highlightColor; duration: 300
                    easing.type: Easing.OutQuart
                }
                ColorAnimation {
                    target: highlightRect; property: "color"
                    to: "transparent"; duration: 300
                    easing.type: Easing.InQuint
                }
            }
        }

        Column {
            id: mainColumn
            anchors {
                left: parent.left; margins: constant.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            height: childrenRect.height
            width: commentDelegate.width - lineRow.width - 2 * constant.paddingMedium
            spacing: constant.paddingSmall

            Row {
                id: bubbleRow
                visible: model.isStickied || model.gilded > 0
                spacing: constant.paddingMedium

                Bubble {
                    visible: model.isStickied
                    font.pixelSize: constant.fontSizeSmaller
                    text: qsTr("Sticky")
                    color: "green"
                }
                Bubble {
                    visible: model.gilded > 0
                    font.pixelSize: constant.fontSizeSmaller
                    font.bold: true
                    text: model.gilded > 1 ? qsTr("Gilded") + " " + model.gilded + "x" : qsTr("Gilded")
                    color: "gold"
                }
            }

            Flow {
                id: flowItem
                anchors { left: parent.left; right: parent.right }
                width: parent.width
                spacing: constant.paddingSmall
                bottomPadding: constant.paddingSmall

                Item {
                    id: authorItem
                    width: author.width
                    height: author.height - constant.paddingSmall
                    Text {
                        id: author
                        font.pixelSize: constant.fontSizeDefault
                        color: (mainItem.enabled && model.isValid) ? (mainItem.highlighted ? Theme.highlightColor : constant.colorMidLight)
                                                                   : constant.colorDisabled
                        font.bold: true
                        font.italic: model.author.split(" ").length > 1
                        text: model.author
                    }
                }

                Item {
                    width: submitter.width
                    height: author.height
                    visible: model.isSubmitter
                    Text {
                        id: submitter
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: constant.fontSizeSmaller
                        color: (mainItem.enabled && model.isValid) ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                                                   : constant.colorDisabled
                        font.bold: true
                        text: "[S]"
                    }
                }

                Item {
                    width: distinguished.width
                    height: author.height
                    visible: model.distinguished !== CommentModel.NotDistinguised
                    Text {
                        id: distinguished
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: constant.fontSizeSmaller
                        color: (mainItem.enabled && model.isValid) ? (mainItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                                                   : constant.colorDisabled
                        font.bold: true
                        text: model.distinguished === CommentModel.DistinguishedByAdmin ? "[A]" :
                              model.distinguished === CommentModel.DistinguishedByMod ? "[M]" :
                              model.distinguished === CommentModel.DistinguishedBySpecial ? "[!]" : ""
                    }
                }

                Item {
                    width: bubble.width + 2 * constant.paddingSmall
                    height: Math.max(author.height, bubble.height)
                    visible: model.authorFlairText !== ""
                    Bubble {
                        id : bubble
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.authorFlairText
                        font.pixelSize: constant.fontSizeSmaller
                    }
                }

                Item {
                    width: dot1.width
                    height: author.height
                    Text {
                        id: dot1
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: constant.fontSizeSmaller
                        color: (mainItem.enabled && model.isValid) ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                                                   : constant.colorDisabled
                        text: "·"
                    }
                }

                Item {
                    width: score.width
                    height: author.height
                    Text {
                        id: score
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: constant.fontSizeSmaller
                        text: model.isScoreHidden ? qsTr("[score hidden]")
                                                  : (model.score < 0 ? "-" : "") + qsTr("%n pts", "", Math.abs(model.score))
                        color: {
                            if (!mainItem.enabled || !model.isValid)
                                return constant.colorDisabled;
                            if (model.likes > 0)
                                return constant.colorLikes;
                            else if (model.likes < 0)
                                return constant.colorDislikes;
                            else
                                return mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid;
                        }
                    }
                }

                Item {
                    width: dot2.width
                    height: author.height
                    Text {
                        id: dot2
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: constant.fontSizeSmaller
                        color: (mainItem.enabled && model.isValid) ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                                                   : constant.colorDisabled
                        text: "·"
                    }
                }

                Item {
                    width: created.width
                    height: author.height
                    Text {
                        id: created
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: constant.fontSizeSmaller
                        color: (mainItem.enabled && model.isValid) ? (mainItem.highlighted ? Theme.secondaryHighlightColor : constant.colorMid)
                                                                   : constant.colorDisabled
                        text: model.created
                    }
                }
            }

            WideText {
                id: bodyText
                body: model.body
                listItem: mainItem
                width: parent.width
                onClicked: commentDelegate.clicked()
            }

        }

        Image {
            visible: model.saved
            anchors {
                right: parent.right
                top: parent.top
                topMargin: 5
                rightMargin: 5
            }
            source: "image://theme/icon-s-favorite?" + Theme.highlightColor
        }

        onClicked: commentDelegate.clicked();
    }

    Rectangle {
        id: savedRect
        anchors.fill: parent
        color: Theme.highlightColor
        visible: model.saved
        opacity: 0.1
    }

    Loader {
        id: moreChildrenLoader
        anchors {
            left: lineRow.right;
            right: parent.right;
            top: (mainItem.visible ? mainItem.bottom : mainItem.top);
            margins: constant.paddingMedium
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
                property real buttonScale: __buttonScale()

                function __buttonScale() {
                    switch (appSettings.fontSize) {
                    case AppSettings.TinyFontSize: return 0.75;
                    case AppSettings.SmallFontSize: return 0.90;
                    default: return 1;
                    }
                }

                Button {
                    id: loadMoreButton
                    scale: morechildrencolumn.buttonScale
                    text: model.moreChildrenCount > 0 ? qsTr("Load %n hidden comments", "", model.moreChildrenCount) : qsTr("Continue this thread");

                    onClicked: {
                        if (model.moreChildrenCount > 0) {
                            commentPage.loadMoreChildren(model.index, model.moreChildren);
                        } else {
                            var clink = QMLUtils.toAbsoluteUrl("/r/" + link.subreddit + "/comments/" + link.fullname.substring(3) + "//" + model.fullname.substring(3))
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

                property real buttonScale: __buttonScale()

                function __buttonScale() {
                    switch (appSettings.fontSize) {
                    case AppSettings.TinyFontSize: return 0.75;
                    case AppSettings.SmallFontSize: return 0.90;
                    default: return 1;
                    }
                }

                Button {
                    id: expandChildrenButton
                    scale: collapsedChildrenColumn.buttonScale
                    text: qsTr("Show %n collapsed comments", "", model.moreChildrenCount);

                    onClicked: {
                        commentPage.morechildren_animation = true;
                        commentModel.expand(model.fullname);
                    }
                }
            }
        }

        Component {
            id: editComponent

            Column {
                id: editColumn
                height: childrenRect.height
                spacing: 1

                property real buttonScale: __buttonScale()

                function __buttonScale() {
                    switch (appSettings.fontSize) {
                    case AppSettings.TinyFontSize: return 0.75;
                    case AppSettings.SmallFontSize: return 0.90;
                    default: return 1;
                    }
                }

                SectionHeader {
                    text: model.view === "edit" ? qsTr("Editing Comment") :
                          model.view === "reply" ? qsTr("Comment Reply") :
                          model.view === "new" ? qsTr("New Comment") :
                          model.view
                }

                TextArea {
                    id: editTextArea
                    font.pixelSize: constant.fontSizeDefault
                    anchors { left: parent.left; right: parent.right }

                    textMargin: model.view === "reply" ? constant.paddingMedium : 0

                    height: Math.max(implicitHeight, Theme.itemSizeLarge * 2)
                    placeholderText: model.view === "reply" ? qsTr("Enter your reply here...") : qsTr("Enter your new comment here...")
                    focus: true

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: 0.05
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    scale: editColumn.buttonScale; transformOrigin: Item.Top

                    Button {
                        id: acceptButton
                        anchors.leftMargin: constant.paddingLarge

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
                }

                Connections {
                    target: commentManager
                    onSuccess: if (fullname === model.fullname) { commentModel.setView(model.fullname, "") }
                }

                Component.onCompleted: {
                    if (model.view === "edit")
                        editTextArea.text = model.rawBody
                }
            }
        }

    }

}
