import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: aboutPage

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Text {
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        wrapMode: Text.Wrap
        text: "Copyright (c) Dickson Leong\nv" + APP_VERSION + " ALPHA\nApp icon by @andrewzhilin"
    }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "About Quickddit"
    }
}
