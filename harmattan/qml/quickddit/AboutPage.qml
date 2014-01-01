import QtQuick 1.1
import com.nokia.meego 1.0

AbstractPage {
    id: aboutPage
    title: "About Quickddit"

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Text {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: constant.fontSizeLarge
        color: constant.colorLight
        wrapMode: Text.Wrap
        text: "Copyright (c) Dickson Leong\nv" + APP_VERSION + " BETA\nApp icon by @andrewzhilin\n" +
              "Licensed under GNU GPLv3+"
    }
}
