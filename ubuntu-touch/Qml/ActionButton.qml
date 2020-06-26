import QtQuick 2.9
import QtQuick.Controls 2.2

ToolButton {
    height: parent.height
    width: 40
    hoverEnabled: false
    //after QT update we can use icon property
    property url ico
    Image {
        anchors.centerIn: parent
        source: ico
        width: 24
        height: 24
    }
}
