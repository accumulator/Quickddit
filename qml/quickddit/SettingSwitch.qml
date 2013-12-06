import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: settingSwitch

    property string text: ""
    property alias checked: switchItem.checked

    width: parent.width
    height: switchItem.height + 2 * constant.paddingMedium

    Text {
        anchors {
            left: parent.left; right: switchItem.left
            margins: constant.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: constant.fontSizeMedium
        maximumLineCount: 2
        color: constant.colorLight
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        text: settingSwitch.text
    }

    Switch {
        id: switchItem
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; margins: constant.paddingMedium }
    }
}
