import QtQuick 1.1
import com.nokia.meego 1.0

ContextMenu {
    id: root

    property string url

    property bool __isClosing: false

    platformTitle: Text {
        anchors { left: parent.left; right: parent.right }
        horizontalAlignment: Text.AlignHCenter
        text: url
        font.italic: true
        font.pixelSize: constant.fontSizeMedium
        color: constant.colorLight
        elide: Text.ElideRight
        maximumLineCount: 3
        wrapMode: Text.WrapAnywhere
    }

    MenuLayout {
        MenuItem {
            text: "Open URL in web browser"
            onClicked: {
                Qt.openUrlExternally(url);
                infoBanner.alert("Launching web browser...");
            }
        }
        MenuItem {
            text: "Copy link"
            onClicked: {
                QMLUtils.copyToClipboard(link);
                infoBanner.alert("Link copied to clipboard");
            }
        }
    }

    Component.onCompleted: open()

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) root.destroy(250)
    }
}
