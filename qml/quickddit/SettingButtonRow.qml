import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: root

    property string text: ""
    property variant buttonsText: []
    property int checkedButtonIndex: 0

    signal buttonClicked(int index)

    width: parent.width
    height: settingText.paintedHeight + buttonRow.height + buttonRow.anchors.topMargin

    Text {
        id: settingText
        anchors { left: parent.left; top: parent.top; leftMargin: constant.paddingMedium }
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        text: root.text
    }

    ButtonRow {
        id: buttonRow
        anchors {
            top: settingText.bottom
            left: parent.left
            right: parent.right
            margins: constant.paddingSmall
        }

        Repeater {
            id: buttonRepeater
            model: root.buttonsText

            Button {
                text: modelData
                onClicked: root.buttonClicked(index)
            }
        }
    }

    Component.onCompleted: {
        if (buttonRepeater.count > 0)
            buttonRow.checkedButton = buttonRepeater.itemAt(root.checkedButtonIndex)
    }
}
