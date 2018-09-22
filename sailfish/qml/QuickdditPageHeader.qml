/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2015-2018  Sander van Grieken

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

PageHeader {
    IconButton {
        id: button
        anchors.verticalCenter: extraContent.verticalCenter
        anchors.left: extraContent.left
        anchors.leftMargin: constant.paddingMedium

        icon.source: "image://theme/icon-m-mail"
        visible: inboxManager.hasUnseenUnread
        highlighted: false

        onVisibleChanged: {
            var item = parent
            while (item) {
                if (item.hasOwnProperty('__silica_page')) {
                    item.showNavigationIndicator = !visible
                    break;
                }
                item = item.parent
            }
        }

        onClicked: {
            if (pageStack.currentPage.objectName === "messagePage") {
                pageStack.currentPage.section = MessageModel.AllSection
                pageStack.currentPage.refresh();
            } else {
                pageStack.push(Qt.resolvedUrl("MessagePage.qml"), { section: MessageModel.AllSection });
            }
        }
    }

}

