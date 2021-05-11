/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.12
import QtQuick.Controls 2.12
import quickddit.Core 1.0
import "../"
import "../Delegates"

Page {
    title: qsTr("Accounts")

    ListView {
        id:accountsView
        anchors.fill: parent

        model:appSettings.accountNames

        delegate: ItemDelegate {
            width: parent.width
            text: modelData
            highlighted: modelData === appSettings.redditUsername

            ToolButton {
                anchors.right: parent.right
                anchors.rightMargin: 12
                height: parent.height
                hoverEnabled: false
                icon.name: "edit-delete-symbolic"
                icon.color: persistantSettings.redColor

                onClicked: {
                    if(modelData === appSettings.redditUsername )
                        quickdditManager.signOut();
                    appSettings.removeAccount(modelData);
                }
            }
            onClicked: {
                quickdditManager.selectAccount(modelData);
                globalUtils.getMainPage().refresh();
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition);
            }
        }

        footer: ItemDelegate {
            width: parent.width
            text: qsTr("Add new account")

            onClicked: {
                quickdditManager.signOut();
                pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/LoginPage.qml"));
            }
        }
    }

}
