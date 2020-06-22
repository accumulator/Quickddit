import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

Page {
    property alias imageUrl: viewer.source
    property alias imgurUrl: imgurManager.imgurUrl

    Flickable{
        id:f
        anchors.fill: parent
        contentHeight: viewer.height
        contentWidth: viewer.width
        onHeightChanged: {
            viewer._fitToScreen();
        }
        ImageViewer{
            id:viewer
            flickable: f
        }
    }

    ImgurManager {
        id: imgurManager
        manager: quickdditManager
        onError: {
            infoBanner.warning(errorString);
        }
    }

    Binding {
        target: viewer
        property: "source"
        value: imgurManager.imageUrl
        when: imgurUrl
    }

}
