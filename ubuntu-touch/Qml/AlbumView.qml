import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

//TODO: implement Imgur album viewer
Item {
    property string url

    height: visible ? zimg.height: 0

    ZoomableImage {
        id:zimg
        width: parent.width
        height: previewableImage?width/link.previewWidth*link.previewHeight:0
        source: url
        visible: true
    }
}
