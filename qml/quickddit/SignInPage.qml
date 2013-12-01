import QtQuick 1.1
import com.nokia.meego 1.0
import QtWebKit 1.0

Page {
    id: signInPage

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: signInWebView.url = quickdditManager.generateAuthorizationUrl();
        }
    }

    Flickable {
        id: websiteFlickable
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: signInWebView.height
        contentWidth: signInWebView.width

        WebView {
            id: signInWebView
            preferredHeight: websiteFlickable.height
            preferredWidth: websiteFlickable.width
            onUrlChanged: {
                if (url.toString().indexOf("code=") > 0) {
                    stop.trigger();
                    quickdditManager.getAccessToken(url);
                    pageHeader.busy = true;
                }
            }
            onLoadStarted: pageHeader.busy = true;
            onLoadFailed: pageHeader.busy = false;
            onLoadFinished: pageHeader.busy = false;
        }

        // TODO: pinch zooming for WebView

//        PinchArea {
//            id: pinchArea
//            anchors.fill: parent
//            pinch.target: signInWebView
//        }
    }

    ScrollDecorator { flickableItem: websiteFlickable }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "Sign in to Reddit"
    }

    Connections {
        target: quickdditManager
        onAccessTokenSuccess: {
            pageHeader.busy = false;
            infoBanner.alert("Sign in successfully! Welcome! :)");
            mainPage.refreshToFrontPage();
            pageStack.pop();
        }
        onAccessTokenFailure: {
            pageHeader.busy = false;
        }
    }

    Component.onCompleted: signInWebView.url = quickdditManager.generateAuthorizationUrl();
}
