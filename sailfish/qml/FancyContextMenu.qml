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

ContextMenu {
    id: contextMenu

    property Item _highlightBar

    Component.onCompleted: {
        // find highlight rectangle
        for (var i=0; i<contextMenu.data.length; i++) {
            var childItem = contextMenu.data[i];
            if (childItem.hasOwnProperty("highlightedItem")) {
                // got the highlightbar
                _highlightBar = childItem;
            }
        }
        if (!_highlightBar)
            console.log("HighlightBar not found!");
    }

    onPositionChanged: {
        // propagate x-position since jolla's contextmenu doesn't remember it.
        if (_highlightedItem && _highlightedItem.hasOwnProperty("xPos"))
            _highlightedItem.xPos = _contentColumn.mapFromItem(contextMenu, mouse.x, mouse.y).x;
    }

}

