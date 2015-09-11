/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2015  Sander van Grieken

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

Rectangle {
    id: container
    border.color: "white"
    border.width: 1

    color: "transparent"

    width: refresh.width + captcha.width + constant.paddingLarge + 2 * border.width
    height: captcha.height + description.height + _userInput.height // + 2 * constant.paddingSmall + 2 * border.width

    property alias userInput: _userInput
    property real captchaScale: 2

    Column {
        spacing: constant.paddingSmall

        anchors {
            left: parent.left
            leftMargin: parent.border.width
            right: parent.right
            rightMargin: parent.border.width
            top: parent.top
            topMargin: parent.border.width
        }

        Row {
            spacing: constant.paddingLarge

            Image {
                id: refresh
                source: "image://theme/icon-m-refresh"
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // defocus _userInput first, otherwise clearing the textfield is problematic
                        refresh.forceActiveFocus()
                        _userInput.text = ""
                        captchaManager.request()
                    }
                }
            }

            Image {
                id: captcha
                source: captchaManager.ready ? captchaManager.imageUrl : ""
                anchors.verticalCenter: parent.verticalCenter

                width: 120 * captchaScale
                height: 50 * captchaScale
            }
        }

        Text {
            id: description
            text: "Enter the Captcha text below"
            font.pixelSize: constant.fontSizeXSmall
            color: constant.colorLight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        TextField {
            id: _userInput
            anchors { left: parent.left; right: parent.right }
        }
    }

    Component.onCompleted: captchaManager.request()
}
