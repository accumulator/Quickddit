/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

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

    implicitWidth: ListView.view ? ListView.view.width : (parent ? parent.width : 0)

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
