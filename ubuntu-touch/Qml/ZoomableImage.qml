import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

//TODO: make it zoomable
Image {

    fillMode: Image.PreserveAspectFit

    Image {
        id: busy
        source: "../Icons/spinner.svg"
        anchors.centerIn: parent
        visible: parent.status===Image.Loading
        width: 48
        height: width
        Timer{
            interval: 150
            onTriggered: busy.rotation+=35
            running: parent.visible
            repeat: true
        }
    }
}
