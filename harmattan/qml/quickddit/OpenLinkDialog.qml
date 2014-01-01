import QtQuick 1.1
import com.nokia.meego 1.0

ContextMenu {
    id: root

    property string url

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
            text: "Copy URL"
            onClicked: {
                QMLUtils.copyToClipboard(url);
                infoBanner.alert("URL copied to clipboard");
            }
        }
    }
}
