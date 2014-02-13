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

Dialog {
    id: selectionDialog

    property alias title: header.title
    property alias model: listView.model
    property int selectedIndex: -1

    canAccept: false

    DialogHeader {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
    }

    ListView {
        id: listView
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        delegate: SimpleListItem {
            selected: selectionDialog.selectedIndex == index
            text: modelData
            onClicked: {
                selectionDialog.selectedIndex = index;
                canAccept = true;
                selectionDialog.accept();
            }
        }
    }
}
