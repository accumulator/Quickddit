import QtQuick 1.1
import com.nokia.meego 1.0

MouseArea {
    id: listItem

    default property alias content: contentItem.children
    property Component menu: null

    property Item __menuObject

    function showMenu(properties) {
        // use the current page as parent so that dialog position correctly
        __menuObject = menu.createObject(appWindow.pageStack.currentPage, properties || {});
        __menuObject.statusChanged.connect(function() {
           if (__menuObject.status == DialogStatus.Closed) {
               __menuObject.destroy(250);
               if (listItem.ListView.view)
                   listItem.ListView.view.interactive = true;
           }
       })
        __menuObject.open();
        // to avoid the delegate being scroll out and destroy which will
        // cause the dialog to destroy "brutally"
        if (ListView.view)
            ListView.view.interactive = false;
        return __menuObject;
    }

    implicitWidth: ListView.view ? ListView.view.width : 0

    Image {
        id: highlight
        anchors.fill: parent
        visible: listItem.pressed
        source: appSettings.whiteTheme ? "image://theme/meegotouch-panel-background-pressed"
                                       : "image://theme/meegotouch-panel-inverted-background-pressed"
    }

    Item {
        id: contentItem
        height: parent.height; width: parent.width
    }
}
