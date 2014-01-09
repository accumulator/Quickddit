import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: textAreaDialog

    property alias text: textArea.text
    property alias titleText: headerItemText.text

    acceptButtonText: "Accept"
    rejectButtonText: "Cancel"
    acceptButton.enabled: text.length > 0 || textArea.platformPreedit.length > 0

    onAccepted: textArea.parent.focus = true; // force commit of predictive text

    content: Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: flickableColumn.height + 2 * constant.paddingMedium

        Column {
            id: flickableColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            Text {
                id: headerItemText
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                font.pixelSize: constant.fontSizeXLarge
                color: constant.colorLight
                elide: Text.ElideRight
            }

            TextArea {
                id: textArea
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                height: Math.max(implicitHeight, 300)
                font.pixelSize: constant.fontSizeLarge
                textFormat: Text.PlainText
                placeholderText: "Tap here to type..."
            }
        }
    }
}
