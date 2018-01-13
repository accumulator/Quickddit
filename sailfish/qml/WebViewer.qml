/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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

AbstractPage {
    id: webViewPage
    title: qsTr("WebViewer")
    property url url: webView.url
    property url _prevUrl: ""

    onUrlChanged: {
        if (url != _prevUrl)
            webView.url = url
        _prevUrl = url
    }

    SilicaWebView {
        id: webView
        anchors.fill: parent

        experimental.overview: true
        experimental.customLayoutWidth: webViewPage.width / (0.5 + QMLUtils.pScale)

        onLoadingChanged: {
            busy = loading
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy URL")
                onClicked: {
                    QMLUtils.copyToClipboard(url);
                    infoBanner.alert(qsTr("URL copied to clipboard"));
                }
            }
            MenuItem {
                text: qsTr("Open in browser")
                onClicked: {
                    Qt.openUrlExternally(url);
                }
            }
            MenuItem {
                text: qsTr("Back")
                visible: webView.canGoBack
                onClicked: webView.goBack()
            }
            MenuItem {
                text: qsTr("Forward")
                visible: webView.canGoForward
                onClicked: webView.goForward()
            }
        }
    }

    Rectangle {
        id: overlay
        visible: busy
        anchors.fill: webView
        color: "black"
        opacity: 0.5
    }

    BusyIndicator {
        anchors.centerIn: overlay
        running: overlay.visible
        size: BusyIndicatorSize.Large
    }

}

