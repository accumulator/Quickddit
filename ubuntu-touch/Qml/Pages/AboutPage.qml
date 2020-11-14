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
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0

Page {
    title: qsTr("About")
    ListView {
        anchors.fill: parent
        header:Column {
            id:aboutColumn
            topPadding: 10
            width: parent.width

            Image {
                id: logo
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/Icons/quickddit.svg"
                layer.enabled: true
                width: 120
                height: 120
                sourceSize.height:120
                sourceSize.width:120

                layer.effect:
                    OpacityMask {
                    maskSource: Rectangle {
                        width: logo.width
                        height: logo.height
                        radius: logo.width/5
                    }
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 1
                        verticalOffset: 1
                        color: "#A0000000"

                    }
                }
            }

            Label {
                text: "Quickddit"
                padding: 10
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 18
            }

            Label {
                text: qsTr("A free and open source Reddit client for mobile phones") +
                      "\nv" + APP_VERSION + "\n"+
                      "Copyright (c) 2015-2020 Sander van Grieken\n" +
                      "Copyright (c) 2013-2014 Dickson Leong\n\n" +
                      "Ubuntu touch port by Daniel Kutka \n\n" +
                      qsTr("App icon by Andrew Zhilin") + "\n\n" +
                      //: _translator is used as a placeholder for the name of the translator (you :)
                      (qsTr("_translator") !== "_translator" ? qsTr("Current language translation by %1").arg(qsTr("_translator")) + "\n\n" : "") +
                      qsTr("Licensed under GNU GPLv3+")
                horizontalAlignment: "AlignHCenter"
                padding: 5
                width: parent.width
                wrapMode: "WordWrap"
            }
        }

        model: [
            { name: qsTr("Get the source"), url: QMLUtils.SOURCE_REPO_URL },
            { name: qsTr("Report issues"),  url: "https://github.com/accumulator/Quickddit/issues" },
            { name: qsTr("Translations"), url: QMLUtils.TRANSLATIONS_URL },
            { name: qsTr("Licence"), url: QMLUtils.GPL3_LICENSE_URL },
        ]

        delegate: ItemDelegate {
            width: parent.width
            text: modelData.name
            contentItem.anchors.horizontalCenter: horizontalCenter
            onClicked: Qt.openUrlExternally(modelData.url)
        }

        footer: ItemDelegate {
            width: parent.width
            text: qsTr("Donate")
            onClicked: pageStack.push(Qt.resolvedUrl("qrc:/Qml/Pages/DonatePage.qml"))

        }
    }
}
