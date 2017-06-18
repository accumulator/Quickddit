/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2017  Sander van Grieken

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
import harbour.quickddit.Core 1.0

ContextMenu {
    id: messageMenu

    property variant message
    property MessageManager messageManager
    property bool enableMarkRead: true

    MenuItem {
        enabled: enableMarkRead && !messageManager.busy
        text: message.isUnread ? qsTr("Mark As Read") : qsTr("Mark As Unread")
        onClicked: message.isUnread ? messageManager.markRead(message.fullname)
                                    : messageManager.markUnread(message.fullname);
    }
}
