import QtQuick 1.1
import com.nokia.meego 1.0

ContextMenu {
    id: linkDialog

    property variant link

    property bool __isClosing: false

    MenuLayout {
        MenuItem {
            text: "URL"
            onClicked: globalDialogManager.createOpenLinkDialog(mainPage, link.url);
        }
        MenuItem {
            text: "View image"
            enabled: {
                if (link.domain == "i.imgur.com" || link.domain == "imgur.com")
                    return true;
                if (/^https?:\/\/.+\.(jpe?g|png|gif)/i.test(link.url))
                    return true;
                else
                    return false;
            }
            onClicked: {
                var p = {};
                if (link.domain == "imgur.com")
                    p.imgurUrl = link.url;
                else
                    p.imageUrl = link.url;
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), p);
            }
        }
    }

    Component.onCompleted: open();

    onStatusChanged: {
        if (status === DialogStatus.Closing) __isClosing = true
        else if (status === DialogStatus.Closed && __isClosing) linkDialog.destroy(250)
    }
}
