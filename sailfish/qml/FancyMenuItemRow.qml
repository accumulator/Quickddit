/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016,2019  Sander van Grieken

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

Row {
    id: menuRow

    spacing: 0

    property FancyContextMenu contextMenu: parent.parent

    // the x position we need to track
    property real xPos
    // calculated item width, equally divided
    property real itemWidth

    signal clicked
    signal delayedClick

    // these get fed from ContextMenu
    property bool down
    property bool highlighted

    // magic needed so jolla's contextmenu recognizes the Row as a menuitem
    property int __silica_menuitem

    // current highlighted item
    property Item _highlightedItem

    function updateHighlightbarFor(item) {
        contextMenu._highlightBar.x = item ? item.x : parent.x
        contextMenu._highlightBar.width = item && item.enabled ? item.width : 0
    }

    function resetHighlightbar() {
        contextMenu._highlightBar.x = parent.x
        contextMenu._highlightBar.width = contextMenu.width
    }

    function calculateItemWidth() {
        var count = menuRow.visibleChildren.length;
        itemWidth = count > 0 ? width/count : width
        width -= (count-1) * spacing
    }

    // first xpos change event is received _after_ we receive the events from
    // the contextmenu, so this is for initialising xpos in those cases.
    function updateXPosFromMenu() {
        if (contextMenu.listItem && settings.commentsTapToHide) { // if listItem is set, events are produced relative listItem
            xPos = _contentColumn.mapFromItem(contextMenu.listItem, contextMenu.listItem.mouseX, contextMenu.listItem.mouseY).x;
        } else {
            xPos = _contentColumn.mapFromItem(contextMenu, contextMenu.mouseX, contextMenu.mouseY).x;
        }
    }

    onXPosChanged: {
        var item = childAt(xPos, 0);
        if (item !== _highlightedItem) {
            if (_highlightedItem)
                _highlightedItem.down = false
            updateHighlightbarFor(item);
            _highlightedItem = item
            if (_highlightedItem)
                _highlightedItem.down = down
        }
    }

    onDownChanged: {
        if (down) {
            updateXPosFromMenu();
            var item = childAt(xPos, 0);
            updateHighlightbarFor(item);
            _highlightedItem = item
            if (_highlightedItem)
                _highlightedItem.down = true
        } else {
            resetHighlightbar();
            if (_highlightedItem)
                _highlightedItem.down = false
            _highlightedItem = null
        }
    }

    onClicked: {
        updateXPosFromMenu();
        var item = childAt(xPos, 0);
        if (item)
            if (item.enabled)
                item.clicked();
            // else: prevent menu from being closed, because the Row is always enabled
    }

    Binding {
        target: menuRow
        property: "width"
        value: contextMenu.width
    }

    onWidthChanged: {
        calculateItemWidth();
    }

}

