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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: simpleListItem

    property alias text: labelItem.text
    property bool selected: false

    contentHeight: Theme.itemSizeSmall
    width: ListView.view ? ListView.view.width : parent.width

    Label {
        id: labelItem
        anchors {
            left: parent.left; right: parent.right; margins: constant.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        font.bold: selected
        font.pixelSize: constant.fontSizeMedium
        color: simpleListItem.enabled ? (simpleListItem.selected ? Theme.highlightColor : constant.colorLight)
                                      : constant.colorDisabled
        elide: Text.ElideRight
    }
}
