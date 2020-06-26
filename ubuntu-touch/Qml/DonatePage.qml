import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    title: "Donate"

    property string _paypalLink: "https://paypal.me/sanderdonate"
    property string _bitcoinAddr: "3NhheF8z8sTxpbsCVUpW6HWH8DpADoH46m"
    property string  _paypalLink_dk: "https://PayPal.Me/DanielKutka"
    ScrollView {
        anchors.fill: parent
        Column {
            width: parent.parent.width
            anchors.horizontalCenter: parent
            padding: 10
            spacing: 8
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 16
                text: "Sander van Grieken "
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "(maintainer)"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 48
                height: width
                source: "../Img/paypal.png"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "Donate via PayPal:"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "<a href=\"" + _paypalLink + "\">" + _paypalLink + "</a>"
                onLinkActivated: Qt.openUrlExternally(_paypalLink);
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 48
                height: width
                source: "../Img/bitcoin.png"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "Donate via Bitcoin:"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "<a href=\"" + _bitcoinAddr + "\">" + _bitcoinAddr + "</a>"
                onLinkActivated: {
                    QMLUtils.copyToClipboard(_bitcoinAddr)
                    infoBanner.alert("Address copied to clipboard")
                }
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 16
                text: "Daniel Kutka"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "(ubuntu-touch port)"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 48
                height: width
                source: "../Img/paypal.png"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "Donate via PayPal:"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 12
                text: "<a href=\"" + _paypalLink_dk + "\">" + _paypalLink_dk + "</a>"
                onLinkActivated: Qt.openUrlExternally(_paypalLink_dk);
            }
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
