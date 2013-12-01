import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

Item {
    id: commentDelegate
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

    AbstractListItem {
        id: mainItem
        anchors { left: lineRow.right; right: parent.right }
        height: mainColumn.height + 2 * constant.paddingMedium

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
                    color: constant.colorLight
                    font.bold: true
                    text: model.author
                }

                Loader {
                    id: scoreLoader
                    anchors { left: commentAuthorText.right; leftMargin: constant.paddingSmall }
                    sourceComponent: model.isScoreHidden ? scoreHiddenComponent : scoreBubbleComponent

                    Component {
                        id: scoreBubbleComponent
                        CountBubble {
                            largeSized: true
                            value: model.score
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
                    color: constant.colorMid
                    elide: Text.ElideRight
                    text: model.created
                }
            }

            Text {
                id: commentBodyText
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                wrapMode: Text.Wrap
                text: model.body
            }
        }
    }
}
