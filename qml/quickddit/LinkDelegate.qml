import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1

AbstractListItem {
    id: delegate

    property bool showSubreddit: true

    height: Math.max(thumbnail.height, textColumn.height) + (2 * constant.paddingMedium)

    Column {
        id: textColumn
        anchors {
            left: parent.left; right: thumbnail.left; margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height
        spacing: constant.paddingSmall

        Text {
            id: titleText
            anchors { left: parent.left; right: parent.right }
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 3
            font.pixelSize: constant.fontSizeDefault
            color: constant.colorLight
            font.bold: true
            text: model.title + " (" + model.domain + ")"
        }

        Text {
            id: timeAndAuthorText
            anchors { left: parent.left; right: parent.right }
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 2
            font.pixelSize: constant.fontSizeDefault
            color: constant.colorMid
            text: "submitted " + model.created + " by " + model.author +
                  (showSubreddit ? " to " + model.subreddit : "")
        }

        Row {
            anchors { left: parent.left; right: parent.right }
            spacing: constant.paddingMedium

            CountBubble {
                largeSized: true
                value: model.score
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: constant.fontSizeDefault
                color: constant.colorLight
                text: "points"
            }

            CountBubble {
                largeSized: true
                value: model.commentsCount
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
                visible: model.isSticky
                text: "Sticky"
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

    Image {
        id: thumbnail
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: constant.paddingMedium }
        source: model.thumbnailUrl
        asynchronous: true
    }

    onClicked: pageStack.push(Qt.resolvedUrl("CommentPage.qml"), { link: model });
}
