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
            mainPage.refresh("");
            pageStack.pop(mainPage);
        }
        onAccessTokenFailure: {
            signInPage.busy = false;
        }
    }

    Component.onCompleted: signInWebView.url = quickdditManager.generateAuthorizationUrl();
}
