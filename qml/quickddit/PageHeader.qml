import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    property string text
    property bool busy: false

    signal clicked

    height: constant.headerHeight
    implicitWidth: parent.width

    BorderImage {
        id: background
        anchors.fill: parent
        border { top: 15; left: 15; right: 15 }
        source: "image://theme/meegotouch-view-header-fixed" + (appSettings.whiteTheme ? "" : "-inverted")
                + (mouseArea.pressed ? "-pressed" : "")
    }

    Text {
        id: mainText
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: busyLoader.left
            margins: constant.paddingLarge
        }
        font.pixelSize: constant.fontSizeXLarge
        color: constant.colorLight
        elide: Text.ElideRight
        text: root.text
    }

    Loader {
        id: busyLoader
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right; rightMargin: constant.paddingLarge
        }
        sourceComponent: busy ? updatingIndicator : undefined

        Component { id: updatingIndicator; BusyIndicator { running: true } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
