import QtQuick 2.9
import QtWebEngine 1.7
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import Qt.labs.platform 1.0

Page {
    WebEngineView{
        anchors.fill: parent
        id:loginPage
        settings.localContentCanAccessFileUrls: true
        settings.localContentCanAccessRemoteUrls: true
        profile: WebEngineProfile{
            persistentStoragePath: StandardPaths.writableLocation(StandardPaths.DataLocation).toString().substring(7)
        }

        onUrlChanged: {
            if (url.toString().indexOf("code=") > 0) {
                stop();
                quickdditManager.getAccessToken(url);
            }
        }
    }


    Connections {
        target: quickdditManager
        onAccessTokenSuccess: {
            infoBanner.alert("Sign in successful! Welcome! :)");
            //inboxManager.resetTimer();
            var mainPage = globalUtils.getMainPage();
            mainPage.refresh("Subscribed");
            pageStack.pop(mainPage);
        }
        onAccessTokenFailure: {
            infoBanner.warning("error");
        }
    }
    Component.onCompleted: loginPage.url = quickdditManager.generateAuthorizationUrl();
}
