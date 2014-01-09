import QtQuick 1.1

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

    width: ListView.view.width
    height: mainItem.height

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
                    width: 2
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
        height: mainColumn.height + 2 * constant.paddingMedium
        enabled: model.isValid

        Rectangle {
            id: highlightRect
            anchors.fill: parent
            color: "transparent"

            SequentialAnimation {
                id: highlightAnimation

                ColorAnimation {
                    target: highlightRect; property: "color"
                    to: "dodgerblue"; duration: 300
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
                left: parent.left; right: parent.right; margins: constant.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            height: authorTextWrapper.height + commentBodyText.paintedHeight
            spacing: constant.paddingSmall

            Item {
                id: authorTextWrapper
                anchors { left: parent.left; right: parent.right }
                height: scoreLoader.height

                Text {
                    id: commentAuthorText
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    font.pixelSize: constant.fontSizeDefault
                    color: mainItem.enabled ? constant.colorLight : constant.colorDisabled
                    font.bold: true
                    text: model.author
                }

                Loader {
                    id: scoreLoader
                    anchors { left: commentAuthorText.right; leftMargin: constant.paddingSmall }
                    sourceComponent: model.isScoreHidden ? scoreHiddenComponent : scoreBubbleComponent

                    Component {
                        id: scoreBubbleComponent
                        CustomCountBubble {
                            value: model.score
                            colorMode: model.likes
                        }
                    }

                    Component {
                        id: scoreHiddenComponent
                        Text {
                            font.pixelSize: constant.fontSizeDefault
                            color: constant.colorMid
                            text: "[score hidden]"
                        }
                    }
                }

                Text {
                    anchors {
                        left: scoreLoader.right
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: constant.paddingSmall
                    }
                    font.pixelSize: constant.fontSizeDefault
                    color: mainItem.enabled ? constant.colorMid : constant.colorDisabled
                    elide: Text.ElideRight
                    text: model.created
                }
            }

            Text {
                id: commentBodyText
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeDefault
                color: mainItem.enabled ? constant.colorLight : constant.colorDisabled
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: model.body
                onLinkActivated: globalUtils.openInTextLink(link);
            }
        }

        onClicked: commentDelegate.clicked();
    }
}
