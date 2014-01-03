import QtQuick 2.0
import Sailfish.Silica 1.0

AbstractPage {
    id: aboutPage
    title: "About Quickddit"

    PageHeader {
        anchors { top: parent.top; right: parent.right; left: parent.left }
        title: aboutPage.title
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
