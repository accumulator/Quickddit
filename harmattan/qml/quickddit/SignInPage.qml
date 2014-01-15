/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

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

import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0

AbstractPage {
    id: signInPage
    title: "Sign in to Reddit"

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: signInWebView.reload.trigger();
        }
    }

    Flickable {
        id: webViewFlickable
        anchors.fill: parent
        contentHeight: signInWebView.height
        contentWidth: signInWebView.width

        WebView {
            id: signInWebView
            preferredHeight: webViewFlickable.height
            preferredWidth: webViewFlickable.width
            onUrlChanged: {
                if (url.toString().indexOf("code=") > 0) {
                    stop.trigger();
                    quickdditManager.getAccessToken(url);
                    signInPage.busy = true;
                }
            }
            onLoadStarted: signInPage.busy = true;
            onLoadFailed: signInPage.busy = false;
            onLoadFinished: signInPage.busy = false;
        }
    }

    ScrollDecorator { flickableItem: webViewFlickable }

    Connections {
        target: quickdditManager
        onAccessTokenSuccess: {
            signInPage.busy = false;
            infoBanner.alert("Sign in successfully! Welcome! :)");
            var mainPage = pageStack.find(function(page) { return page.objectName == "mainPage"; });
            mainPage.refresh();
            pageStack.pop(mainPage);
        }
        onAccessTokenFailure: {
            signInPage.busy = false;
        }
    }

    Component.onCompleted: signInWebView.url = quickdditManager.generateAuthorizationUrl();
}
