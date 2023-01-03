/*
  Quickddit - Reddit client for mobile phones

  SPDX-FileCopyrightText:  Copyright (C) 2014  Dickson Leong
  SPDX-FileCopyrightText:  Copyright (C) 2022  Sander van Grieken
  SPDX-FileCopyrightText:  Copyright (C) 2022  Björn Bidar

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0 as SailfishWebView
import Sailfish.WebView.Popups 1.0 as SailfishWebViewPopups

Dialog {
    id: signInDialog

    // For CoverPage
    property string title: qsTr("Sign in to Reddit")

    backNavigation: webView.atXBeginning && webView.atXEnd && !webView.moving && !webView.pulleyMenuActive
    canAccept: false

    DialogHeader {
        id: dialogHeader

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        //% "Sign in to Reddit with Quickddit"
        title: qsTr("Sign in to Reddit")
        /* Accept text is empty since the dialog will be accepted automatically
         *  when quickdditManager.getAccessToken(url) finds the token.
         */
        acceptText: ""
        cancelText: qsTr("Cancel")
    }


    SilicaFlickable  {
        id: webViewFlickable

        property alias webView: webView

        y: dialogHeader.height + Theme.paddingSmall
        x: parent.x +Theme.paddingSmall
        width: parent.width  - 2*Theme.paddingSmall
        height: parent.height - dialogHeader.height - 2*Theme.paddingSmall


        SailfishWebView.WebView {
            id: webView

            anchors.fill: parent

            url: quickdditManager.generateAuthorizationUrl();
            privateMode: true

            popupProvider: SailfishWebViewPopups.PopupProvider {
                // Disable the Save Password dialog
                passwordManagerPopup: null
            }

            onUrlChanged: {
                if (url.toString().indexOf("code=") > 0) {
                    quickdditManager.getAccessToken(url);
                }
            }
        }
    }

    Connections {
        target: quickdditManager
        onAccessTokenSuccess: {
            infoBanner.alert(qsTr("Sign in successful! Welcome! :)"));
            inboxManager.resetTimer();
            var mainPage = globalUtils.getMainPage();
            mainPage.refresh("");
            backNavigation = true;
            pageStack.pop(mainPage);
        }
    }
}
