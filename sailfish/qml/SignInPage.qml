import QtQuick 2.0
import Sailfish.Silica 1.0

AbstractPage {
    id: signInPage
    title: "Sign in to Reddit"
    busy: webView.loading

    SilicaWebView {
        id: webView
        anchors.fill: parent
        header: PageHeader { title: signInPage.title }

        onUrlChanged: {
            if (url.toString().indexOf("code=") > 0) {
                stop();
                quickdditManager.getAccessToken(url);
                signInPage.busy = true;
            }
        }
    }

    Connections {
        target: quickdditManager
        onAccessTokenSuccess: {
            signInPage.busy = false;
            infoBanner.alert("Sign in successfully! Welcome! :)");
            var mainPage = pageStack.find(function(page) { return page.objectName == "mainPage"; });
            mainPage.refresh("");
            pageStack.pop(mainPage);
        }
        onAccessTokenFailure: {
            signInPage.busy = false;
        }
    }

    Component.onCompleted: webView.url = quickdditManager.generateAuthorizationUrl();
}
