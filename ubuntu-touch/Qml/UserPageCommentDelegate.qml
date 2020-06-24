import QtQuick 2.9
import QtQuick.Controls 2.2

ItemDelegate {
    property variant model
    property bool markSaved: true
    width: parent.width
    height: info.height+comment.height

    Label {
        id:info
        padding: 5
        text: "Comment in <a href='r/"+model.subreddit+"'>"+"r/"+model.subreddit+"</a>"+ " ~ " + (model.score < 0 ? "-" : "") +  qsTr("%n points", "", Math.abs(model.score)) + " ~ "+ model.created
        onLinkActivated: {
            pageStack.push(Qt.resolvedUrl("SubredditPage.qml"),{subreddit:link.slice(2)})
        }
    }

    Row {
        anchors.top: info.bottom
        width: parent.width
        leftPadding: 5
        Rectangle {
            id:rect
            width: 3
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height-6
            color: "#ef9928"
        }

        Label {
            id:comment
            width: parent.width-rect.width
            padding: 5
            bottomPadding: 0
            wrapMode: "WordWrap"
            elide: "ElideRight"
            text: model.body
        }
    }
}
