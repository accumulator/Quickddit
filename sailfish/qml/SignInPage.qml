import QtQuick 2.0
import Sailfish.Silica 1.0

AbstractPage {
    id: signInPage
    title: "Sign in to Reddit"
    busy: webView.loading
    backNavigation: webView.atXBeginning && webView.atXEnd && !webView.moving && !webView.pulleyMenuActive

    SilicaWebView {
        id: webView
        anchors.fill: parent
        header: PageHeader { title: signInPage.title }
        overridePageStackNavigation: true

        onUrlChanged: {
            if (url.toString().indexOf("code=") > 0) {
                stop();
                quickdditManager.getAccessToken(url);
                signInPage.busy = true;
            }
        }

        PullDownMenu {
            MenuItem {
                text: "Cancel"
                onClicked: {
                    backNavigation = true;
                    pageStack.pop();
                }
            }
            MenuItem {
                text: "Reload"
                onClicked: webView.reload();
            }
        }

        ScrollDecorator {}
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
