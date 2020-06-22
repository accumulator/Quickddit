import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property string source
    id: logoRect
    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight
    radius: width;
    color:"white"
    clip: true

    Image{
        anchors.centerIn: parent
        id:image
        source: parent.source
        width: parent.width-10
        height: parent.height-10
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: image.width
                height: image.height
                radius: image.width
            }
        }
    }
}
