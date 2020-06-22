import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
Page {
    title: "About"
    ListView {
        anchors.fill: parent
        header:Column {
            id:aboutColumn
            topPadding: 10
            width: parent.width

            Image {
                id: logo
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../Icons/quickddit.svg"
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
                text: "A free and open source Reddit client for mobile phones" +
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
            { name: "Get the source", url: QMLUtils.SOURCE_REPO_URL },
            { name: "Report issues",  url: "https://github.com/accumulator/Quickddit/issues" },
            { name: "Translations", url: QMLUtils.TRANSLATIONS_URL },
            { name: "Licence", url: QMLUtils.GPL3_LICENSE_URL },
            { name: "Donate", url: "https://PayPal.Me/DanielKutka" }
        ]

        delegate: ItemDelegate {
            width: parent.width
            text: modelData.name
            contentItem.anchors.horizontalCenter: horizontalCenter
            onClicked: Qt.openUrlExternally(modelData.url)
        }
    }
}
