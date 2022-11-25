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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import quickddit.Core 1.0
import QtQuick.Dialogs 1.3

Page {
    title: qsTr("Settings")

    ScrollView {
        contentWidth: width
        anchors.fill: parent

        Column{
            anchors {left: parent.left;right: parent.right}

            SwitchDelegate {
                width: parent.width
                text: qsTr("Compact images in feed (saves data)")
                checked: persistantSettings.compactImages
                onCheckedChanged: persistantSettings.compactImages = checked
            }

            SwitchDelegate {
                width: parent.width
                text: qsTr("Full resolution images (uses more data)")
                checked: persistantSettings.fullResolutionImages
                onCheckedChanged: persistantSettings.fullResolutionImages = checked
            }

            SwitchDelegate {
                width: parent.width
                text: qsTr("Blur NSFW")
                checked: !persistantSettings.enableNSFW
                onCheckedChanged: persistantSettings.enableNSFW = !checked
            }

            ItemDelegate {
                width: parent.width
                Label {
                    id:sliderLabel
                    anchors {left: parent.left;verticalCenter: parent.verticalCenter; margins: Suru.units.gu(2)}
                    text: qsTr("Thumbnail scale:")+" ["+Math.floor(slider.value*100)+"%]"
                }
                Slider {
                    id:slider
                    anchors { right: parent.right; left:sliderLabel.right;  verticalCenter: parent.verticalCenter; margins:Suru.units.gu(2) }
                    from: 0.5
                    to: 1.5
                    stepSize: 0.1
                    snapMode: "SnapAlways"
                    value: persistantSettings.scale
                    live: true
                    onMoved: persistantSettings.scale = value
                }
            }

            ItemDelegate {
                width: parent.width
                Label {
                    anchors {left: parent.left;verticalCenter: parent.verticalCenter; margins: Suru.units.gu(2)}
                    text: "Preferred Video Size"
                }
                ComboBox {
                    anchors { right: parent.right;  verticalCenter: parent.verticalCenter; margins: Suru.units.gu(2) }
                    model: ["360p","720p"]
                    currentIndex: appSettings.preferredVideoSize
                    onCurrentIndexChanged: {
                        appSettings.preferredVideoSize = currentIndex
                    }
                }
            }

            SwitchDelegate {
                width: parent.width
                text: qsTr("Open links internaly")
                checked: persistantSettings.linksInternaly
                onCheckedChanged: persistantSettings.linksInternaly = checked
            }

            SwitchDelegate {
                width: parent.width
                text: qsTr("ToolBar on bottom")
                checked: persistantSettings.toolbarOnBottom
                onCheckedChanged: persistantSettings.toolbarOnBottom = checked
            }

            ItemDelegate {
                width: parent.width
                Label {
                    anchors {left: parent.left;verticalCenter: parent.verticalCenter; margins: Suru.units.gu(2)}
                    text: qsTr("Theme")
                }
                ComboBox {
                    anchors { right: parent.right;  verticalCenter: parent.verticalCenter; margins: Suru.units.gu(2) }
                    model: ["Light","Dark","System"]
                    currentIndex: persistantSettings.theme
                    onCurrentIndexChanged: {
                        persistantSettings.theme = currentIndex
                    }
                }
            }

            ItemDelegate {
                width: parent.width
                text: qsTr("Accounts ")
                onClicked: pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/AccountsPage.qml"));
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Suru.units.gu(2)
                    width: Suru.units.gu(3)
                    height: Suru.units.gu(3)
                    source: "qrc:/Icons/next.svg"
                }
            }
        }
    }
}
