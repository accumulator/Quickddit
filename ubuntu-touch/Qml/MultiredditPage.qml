import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

Page {
    id: aboutMultiredditPage
    objectName: "multiredditPage"
    title: multiredditManager.name

    property alias multireddit: multiredditManager.name
    property alias  mrModel: multiredditManager.model

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: logo.height  + showButton.height + about.height //+ wiki.height
        ScrollBar.vertical.interactive: false

        CircleImage {
            id:logo
            source: multiredditManager.iconUrl
            anchors{left: parent.left;top:parent.top; leftMargin: 20}
            width: Math.min(150,parent.width/4)
            height: width
            Component.onCompleted: console.log(source)
        }

        Label {
            id:fullName
            text: multireddit
            font.pointSize: 18
            anchors{ left: logo.right;bottom: name.top;leftMargin: 20}
        }

        Label {
            id:name
            text: "m/"+multireddit
            anchors{left: logo.right;bottom: logo.bottom;leftMargin: 20}
        }

        Label {
            id:about
            anchors {left: parent.left;right: parent.right;top: name.bottom; margins:10}
            text: multiredditManager.description
            wrapMode: "WordWrap"
        }

        Button {
            id:showButton
            text: "Show posts in m/"+multireddit
            anchors { horizontalCenter: parent.horizontalCenter; top: about.bottom; margins: 10}
            onClicked: {
                globalUtils.getMainPage().refreshMR(multireddit)
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition)
            }
        }
    }

    AboutMultiredditManager {
        id: multiredditManager
        manager: quickdditManager
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.warning(errorString);
    }
}
