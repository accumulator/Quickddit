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

Item {
    id: loadingFooter

    property ListView listViewItem: null

    height: {
        if (!visible)
            return 0;
        if (listViewItem.count === 0)
            return listViewItem.height - (listViewItem.headerItem ? listViewItem.headerItem.height : 0)
        return busyIndicatorLoader.height + 2 * constant.paddingLarge
    }
    width: listViewItem.width

    Loader {
        id: busyIndicatorLoader
        anchors.centerIn: parent
        sourceComponent: loadingFooter.enabled ? busyIndicatorComponent : undefined
    }

    Component {
        id: busyIndicatorComponent

        BusyIndicator {
            running: true
            platformStyle: BusyIndicatorStyle { size: "large" }
        }
    }
}
