import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import quickddit.Core 1.0

Row{
    id:bottomRow

    property variant link
    property VoteManager linkVoteManager
    property SaveManager linkSaveManager

    ToolButton {
        id:up
        flat: true
        hoverEnabled: false
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        //icon.source: "Icons/up.svg"

        onClicked: {
            if (link.likes ===1)
                linkVoteManager.vote(link.fullname, VoteManager.Unvote)
            else
                linkVoteManager.vote(link.fullname, VoteManager.Upvote)
        }

        Image{
            source: link.likes ===1 ? "../Icons/up_b.svg" : "../Icons/up.svg"
            width: 28
            height: 28
            anchors.centerIn: parent
            smooth: true
        }
    }
    Label{
        id:score
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        text: link.score
        horizontalAlignment: "AlignHCenter"
        color:  link.score>0 ? "green" : "red"
    }
    ToolButton {
        id:downn
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        flat: true
        hoverEnabled: false
        enabled: quickdditManager.isSignedIn
        //icon.source: "Icons/down.svg"

        onClicked: {
            if (link.likes ===-1)
                linkVoteManager.vote(link.fullname, VoteManager.Unvote)
            else
                linkVoteManager.vote(link.fullname, VoteManager.Downvote)
        }
        Image{
            source: link.likes ===-1 ? "../Icons/down_b.svg" : "../Icons/down.svg"
            width: 28
            height: 28
            anchors.centerIn: parent
            smooth: true
        }
    }

    ToolButton {
        id:comment
        width: parent.width/6
        anchors.verticalCenter: parent.verticalCenter
        flat: true
        hoverEnabled: false
        //icon.source: "../Icons/message.svg"
        onClicked: {
            if (compact){
                var p = { link: link };
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), p);
            }
        }
        Row {
            id:row
            anchors.centerIn: parent

            Image{
                anchors.verticalCenter: parent.verticalCenter
                source: "../Icons/message.svg"
                width: 24
                height: 24
            }
            Label{
                anchors.verticalCenter: parent.verticalCenter
                text: " "+link.commentsCount
            }
        }
    }

    ToolButton {
        id:share
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        flat: true
        hoverEnabled: false
        //icon.source: "Icons/share.svg"
        Image{
            source: "../Icons/edit-copy.svg"
            width: 24
            height: 24
            anchors.centerIn: parent
        }
        onClicked: {
            QMLUtils.copyToClipboard(link.url)
            infoBanner.alert("Link coppied to clipboard")
        }
    }

    ToolButton {
        id:save
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/6
        enabled: quickdditManager.isSignedIn
        flat:true
        hoverEnabled: false
        Image {
            source: link.saved ? "../Icons/starred.svg" : "../Icons/non-starred.svg"
            width: 24
            height: 24
            anchors.centerIn: parent
        }
        onClicked: {
            linkSaveManager.save(link.fullname,!link.saved)
        }
    }
}
