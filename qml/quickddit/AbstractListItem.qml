import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: abstractListItem

    default property alias content: contentItem.children

    signal clicked
    signal pressAndHold

    implicitWidth: ListView.view ? ListView.view.width : 0

    Image {
        id: highlight
        anchors.fill: parent
        visible: mouseArea.pressed
        source: appSettings.whiteTheme ? "image://theme/meegotouch-panel-background-pressed"
                                       : "image://theme/meegotouch-panel-inverted-background-pressed"
    }

    Item {
        id: contentItem
        height: parent.height; width: parent.width
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: abstractListItem.clicked()
        onPressAndHold: abstractListItem.pressAndHold()
    }
}
