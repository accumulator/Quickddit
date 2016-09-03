/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

AbstractDialog {
    id: selectionDialog

    property alias title: header.title
    property alias model: listView.model
    property int selectedIndex: -1
    property string periodQuery: ""

    canAccept: false

    readonly property variant sectionModel: ["Hot", "New", "Rising", "Controversial", "Top", "Promoted"]

    ListModel {
        id: periodModel
        ListElement { label: "hour"; qry: "" }
        ListElement { label: "day"; qry: "day" }
        ListElement { label: "week"; qry: "week" }
        ListElement { label: "month"; qry: "month" }
        ListElement { label: "year"; qry: "year" }
        ListElement { label: "alltime"; qry: "all" }
    }

    DialogHeader {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
    }

    ListView {
        id: listView
        model: sectionModel
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        delegate: SimpleListItem {
            menu: sectionMenuComponent
            selected: selectionDialog.selectedIndex == index
            text: modelData
            showMenuOnPressAndHold: false
            onPressAndHold: if (index == 3 || index == 4) showMenu({parentItemIndex: index}) // uglyy

            onClicked: {
                selectionDialog.selectedIndex = index;
                canAccept = true;
                selectionDialog.accept();
            }
        }
    }

    Component {
        id: sectionMenuComponent

        ContextMenu {
            property int parentItemIndex

            Repeater {
                model: periodModel
                delegate: MenuItem {
                    highlighted: periodQuery == qry
                    text: label
                    onClicked: {
                        selectionDialog.periodQuery = qry
                        selectionDialog.selectedIndex = parentItemIndex
                        canAccept = true;
                        selectionDialog.accept()
                    }
                }
            }
        }
    }
}
