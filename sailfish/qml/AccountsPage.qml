/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2019  Sander van Grieken

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

import QtQuick 2.6
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: accountsPage
    title: qsTr("Accounts")

    SilicaListView {
        id: accountsFlickable
        anchors.fill: parent

        property bool _completed: false

        Component.onCompleted: _completed = true
        Binding {
            // late-bind model as SilicaListView stubbornly positions view at first item otherwise.
            // hack still needed?
            when: accountsFlickable._completed
            target: accountsFlickable
            property: "model"
            value: settings.accountNames
        }

        header: Column {
            width: parent.width

            QuickdditPageHeader { title: accountsPage.title }
        }

        delegate: ListItem {
            id: listItem
            enabled: modelData !== settings.redditUsername

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: constant.paddingMedium

                IconButton {
                    icon.source: "image://theme/icon-m-person"
                    highlighted: listItem.highlighted || settings.redditUsername === modelData
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    color: listItem.highlighted || settings.redditUsername === modelData ? Theme.highlightColor : constant.colorLight
                    font.pixelSize: constant.fontSizeLarger
                    font.bold: true
                    text: modelData
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            showMenuOnPressAndHold: false
            onPressAndHold: showContextMenu()
            onClicked: showContextMenu()
            function showContextMenu() {
                var dialog = openMenu({item: modelData});
                dialog.removeAccount.connect(function() {
                    listItem.remorseAction(qsTr("Remove %1 account").arg(modelData), function() {
                        settings.removeAccount(modelData);
                    })
                });
                dialog.activateAccount.connect(function() {
                    quickdditManager.selectAccount(modelData);
                    pageStack.pop()
                });
            }

            menu: Component {
                ContextMenu {
                    property string item
                    signal removeAccount
                    signal activateAccount

                    MenuItem {
                        text: qsTr("Activate")
                        onClicked: activateAccount()
                    }
                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: removeAccount()
                    }
                }
            }
        }

        ViewPlaceholder {
            enabled: settings.accountNames.length === 0;
            text: qsTr("No known accounts yet.\n\nTo add accounts, simply log in. Quickddit will remember succesful logins and list the accounts here")
        }
        VerticalScrollDecorator {}
    }
}
