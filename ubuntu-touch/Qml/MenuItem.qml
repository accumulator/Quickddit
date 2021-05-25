import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

MenuItem {
    property string ico
    property string txt
    Row {
        height: parent.height
        spacing: Suru.units.gu(2)
        leftPadding: Suru.units.gu(1)
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: ico
            width: Suru.units.gu(3)
            height: Suru.units.gu(3)
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: txt
        }
    }

}
