import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: openLinkDialog

    property string url

    canAccept: false

    Column {
        anchors { left: parent.left; right: parent.right }

        DialogHeader { title: "URL" }

        Item {
            anchors { left: parent.left; right: parent.right }
            height: urlLabel.height + urlSeparator.height + 2 * constant.paddingLarge

            Label {
                id: urlLabel
                anchors { left: parent.left; right: parent.right; margins: constant.paddingLarge }
                color: Theme.highlightColor
                font.pixelSize: constant.fontSizeMedium
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 3
                elide: Text.ElideRight
                text: url
            }

            Separator {
                id: urlSeparator
                anchors {
                    left: parent.left; right: parent.right
                    top: urlLabel.bottom; topMargin: constant.paddingLarge
                }
                color: constant.colorMid
            }
        }

        ListItem {
            Label {
                anchors {
                    left: parent.left; right: parent.right; margins: constant.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                text: "Open URL in web browser"
            }

            onClicked: {
                Qt.openUrlExternally(url);
                infoBanner.alert("Launching web browser...");
                openLinkDialog.close();
            }
        }

        ListItem {
            Label {
                anchors {
                    left: parent.left; right: parent.right; margins: constant.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                text: "Copy URL"
            }

            onClicked: {
                QMLUtils.copyToClipboard(url);
                infoBanner.alert("URL copied to clipboard");
                openLinkDialog.close();
            }
        }
    }
}
