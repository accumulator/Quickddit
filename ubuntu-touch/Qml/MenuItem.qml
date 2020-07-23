import QtQuick 2.9
import QtQuick.Controls 2.2

MenuItem {
    property string ico
    property string txt
    Row {
        height: parent.height
        spacing: 10
        leftPadding: 10
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: ico
            width: 24
            height: 24
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: txt
        }
    }

}
