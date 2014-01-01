import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: abstractPage

    default property alias data: contentItem.data

    property string title
    property bool busy: false

    signal headerClicked

    Item {
        id: contentItem
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
    }

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: constant.headerHeight

        BorderImage {
            anchors.fill: parent
            border { top: 15; left: 15; right: 15 }
            source: "image://theme/meegotouch-view-header-fixed" + (appSettings.whiteTheme ? "" : "-inverted")
                    + (mouseArea.pressed ? "-pressed" : "")
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left; right: busyLoader.left
                margins: constant.paddingLarge
            }
            font.pixelSize: constant.fontSizeXLarge
            color: constant.colorLight
            elide: Text.ElideRight
            text: abstractPage.title
        }

        Loader {
            id: busyLoader
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right; rightMargin: constant.paddingLarge
            }
            sourceComponent: abstractPage.busy ? updatingIndicator : undefined

            Component { id: updatingIndicator; BusyIndicator { running: true } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: abstractPage.headerClicked();
        }
    }
}
