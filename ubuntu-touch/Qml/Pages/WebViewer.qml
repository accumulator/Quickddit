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
import QtWebEngine 1.7

import "../"

Page {
    title: webView.title
    property url url

    function getButtons(){
        return toolButtons
    }

    Component {
        id: toolButtons
        Row {
            ToolButton {
                enabled: webView.canGoBack
                icon.name: "edit-undo-symbolic"
                onClicked: webView.goBack()
            }

            ToolButton {
                enabled: webView.canGoForward
                icon.name: "edit-redo-symbolic"
                onClicked: webView.goForward()
            }

            ToolButton {
                icon.name: "view-refresh-symbolic"
                onClicked: webView.reload();
            }

            ToolButton {
                icon.name: "emblem-shared-symbolic"
                onClicked: {
                    QMLUtils.copyToClipboard(webView.url)
                    infoBanner.alert(qsTr("Link coppied to clipboard"))
                }
            }

            ToolButton {
                icon.name: "applications-internet"
                onClicked: Qt.openUrlExternally(webView.url);
            }
        }
    }

    WebEngineView{
        anchors.fill: parent
        id:webView
        settings.fullScreenSupportEnabled: true

        onFullScreenRequested: {
            if(request.toggleOn) {
                window.showFullScreen()
            }
            else
                window.showNormal()
            request.accept()
        }

        onNewViewRequested: {
            Qt.openUrlExternally(request.requestedUrl);
        }
    }

    Component.onCompleted: {
        webView.url = url;
    }
}
