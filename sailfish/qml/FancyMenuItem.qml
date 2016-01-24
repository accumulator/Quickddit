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

Label {
    property bool down
    property bool highlighted
    property bool _invertColors

    signal clicked

    width: parent.itemWidth

    onVisibleChanged: {
        parent.calculateItemWidth();
    }

    verticalAlignment: Text.AlignVCenter
    height: Theme.itemSizeSmall
    horizontalAlignment: implicitWidth > width && truncationMode != TruncationMode.None ? Text.AlignLeft : Text.AlignHCenter
    color: enabled ? ((down || highlighted) ^ _invertColors ? Theme.highlightColor : Theme.primaryColor)
                   : Theme.rgba(Theme.secondaryColor, 0.4)
}

