import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import Quickddit 1.0

PageStackWindow {
    id: appWindow

    initialPage: MainPage { id: mainPage }

    InfoBanner {
        id: infoBanner
        topMargin: showStatusBar ? 40 : 8

        function alert(text) {
            infoBanner.text = text
            infoBanner.show()
        }
    }

    QtObject {
        id: globalDialogManager

        property Component __openLinkDialogComponent: null

        function createOpenLinkDialog(parent, url) {
            if (!__openLinkDialogComponent)
                __openLinkDialogComponent = Qt.createComponent("OpenLinkDialog.qml");
            var dialog = __openLinkDialogComponent.createObject(parent, {url: url});
            if (!dialog)
                console.log("Error creating dialog: " + __openLinkDialogComponent.errorString())
        }
    }

    Constant { id: constant }
    AppSettings { id: appSettings }

    Binding {
        target: theme
        property: "inverted"
        value: !appSettings.whiteTheme
    }

    QuickdditManager {
        id: quickdditManager
        settings: appSettings
        onAccessTokenFailure: infoBanner.alert(errorString);
    }

    Component.onCompleted: mainPage.refreshToFrontPage();
}
