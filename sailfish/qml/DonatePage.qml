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

import QtQuick 2.0
import Sailfish.Silica 1.0

AbstractPage {
    id: donatePage
    title: qsTr("Donate")

    property string _paypalLink: "https://paypal.me/sanderdonate"
    property string _bitcoinAddr: "3NhheF8z8sTxpbsCVUpW6HWH8DpADoH46m"

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: contentColumn
            width: parent.width
            spacing: constant.paddingLarge

            QuickdditPageHeader { title: donatePage.title }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "img/paypal.png"
                width: 64 * QMLUtils.pScale
                height: width * (sourceSize.height/sourceSize.width)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Donate via PayPal:")
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: constant.fontSizeMedium
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                onLinkActivated: globalUtils.openLink(_paypalLink);
                text: constant.richtextStyle + "<a href=\"" + _paypalLink + "\">" + _paypalLink + "</a>"
            }

            Rectangle {
                height: constant.paddingLarge
                width: 1
                opacity: 0
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "img/bitcoin.png"
                width: 64 * QMLUtils.pScale
                height: width * (sourceSize.height/sourceSize.width)
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Donate via Bitcoin:")
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "img/btc-qr.png"
                width: 256 * QMLUtils.pScale
                height: width * (sourceSize.height/sourceSize.width)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: constant.fontSizeXSmall
                font.family: "monospace"
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                onLinkActivated: {
                    QMLUtils.copyToClipboard(_bitcoinAddr);
                    infoBanner.alert(qsTr("Address copied to clipboard"));
                }
                text: constant.richtextStyle + "<a href=\"bitcoin:" + _bitcoinAddr + "\">" + _bitcoinAddr + "</a>"
            }

            Rectangle {
                height: constant.paddingLarge
                width: 1
                opacity: 0
            }
        }
    }
}
