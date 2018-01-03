/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
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

AbstractPage {
    id: aboutPage
    title: qsTr("About")

    Image {
        id: backgroundImage
        width: aboutPage.width * 0.8
        height: aboutPage.height * 0.8

        fillMode: Image.PreserveAspectFit
        source: "./cover/background.png"
        visible: false
        smooth: true
    }

    ShaderEffect {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: aboutPage.top
        anchors.topMargin: (aboutPage.height/2 - height/2) - flickable.contentY/3

        width: backgroundImage.paintedWidth; height: backgroundImage.paintedHeight
        property variant source: backgroundImage
        property real frequency: 5
        property real amplitude: 0.02
        property real time: 0.0
        property real myopacity: 0.15

        NumberAnimation on time {
            from: 0; to: Math.PI*2; duration: 3000; loops: Animation.Infinite
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            uniform highp float frequency;
            uniform highp float amplitude;
            uniform highp float time;
            uniform lowp float myopacity;
            void main() {
                highp vec2 pulse = sin(time - frequency * qt_TexCoord0);
                highp vec2 coord = vec2(-amplitude, -amplitude) + qt_TexCoord0 * (1.0 + 2.0 * amplitude) + amplitude * vec2(pulse.x, -pulse.x);
                gl_FragColor = texture2D(source, coord) * myopacity;
            }"
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: header.height + columnWrapper.height
        flickableDirection: Flickable.VerticalFlick

        QuickdditPageHeader { id: header; title: aboutPage.title }

        Item {
            id: columnWrapper
            anchors { left: parent.left; right: parent.right; top: header.bottom }
            height: Math.max(column.height + 2 * constant.paddingMedium, flickable.height - header.height)

            Column {
                id: column
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: childrenRect.height
                spacing: Theme.paddingLarge

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "image://theme/harbour-quickddit"
                }

                Text {
                    anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: constant.fontSizeMedium
                    color: Theme.highlightColor
                    wrapMode: Text.Wrap
                    text: qsTr("Quickddit - A free and open source Reddit client for mobile phones") +
                          "\nv" + APP_VERSION
                }

                Text {
                    anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium }
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: constant.fontSizeSmall
                    color: constant.colorLight
                    wrapMode: Text.Wrap
                    text: "Copyright (c) 2015-2018 Sander van Grieken\n" +
                          "Copyright (c) 2013-2014 Dickson Leong\n\n" +
                          qsTr("App icon by Andrew Zhilin") + "\n\n" +
                          (qsTr("_translator") !== "_translator" ? qsTr("Current language translation by %1").arg(qsTr("_translator")) + "\n\n" : "") +
                          qsTr("Licensed under GNU GPLv3+")
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingLarge

                    Button {
                        text: qsTr("Source")
                        onClicked: globalUtils.createOpenLinkDialog(QMLUtils.SOURCE_REPO_URL);
                    }

                    Button {
                        text: qsTr("License")
                        onClicked: globalUtils.createOpenLinkDialog(QMLUtils.GPL3_LICENSE_URL);
                    }
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Translations")
                    onClicked: globalUtils.createOpenLinkDialog(QMLUtils.TRANSLATIONS_URL);
                }
            }
        }
    }
}
