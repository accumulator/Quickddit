import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: subredditDelegate
    contentHeight: mainColumn.height + 2 * constant.paddingMedium

    Column {
        id: mainColumn
        anchors {
            left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
            margins: constant.paddingMedium
        }
        height: childrenRect.height
        spacing: constant.paddingSmall

        Text {
            id: titleText
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeDefault
            color: constant.colorLight
            font.bold: true
            text: model.url
        }

        Text {
            id: descriptionText
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeDefault
            color: constant.colorMid
            wrapMode: Text.Wrap
            visible: text != ""
            text: model.shortDescription
        }

        Row {
            anchors { left: parent.left; right: parent.right }
            spacing: constant.paddingMedium
            height: subscribersBubble.height

            CustomCountBubble {
                id: subscribersBubble
                value: model.subscribers
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                wrapMode: Text.Wrap
                text: "subscribers"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: "red"
                visible: model.isNSFW
                text: "NSFW"
            }
        }
    }
}
