import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

ApplicationWindow {
    id: appWindow
    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml");

    // Global busy indicator, it reads the 'busy' property from the current page
    DockedPanel {
        id: busyPanel
        width: parent.width
        height: busyIndicator.height + constant.paddingLarge
        open: pageStack.currentPage.hasOwnProperty('busy') ? pageStack.currentPage.busy : false
        dock: Dock.Bottom

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            running: busyPanel.open
        }
    }

    // FIXME: make a replacement for info banner
    QtObject {
        id: infoBanner

        function alert(text) {
            console.log("infoBanner.alert():", text);
        }
    }

    // A collections of global utility functions
    QtObject {
        id: globalUtils

        property Component __openLinkDialogComponent: null

        function openInTextLink(url) {
            url = String(url); // convert to string
            if (url.indexOf("http") != 0)
                url = QMLUtils.getRedditFullUrl(url);

            if (/^https?:\/\/imgur\.com/.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imgurUrl: url});
            else if (/^https?:\/\/i\.imgur\.com/.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imageUrl: url});
            else if (/^https?:\/\/.+\.(jpe?g|png|gif)/i.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imageUrl: url});
            else
                createOpenLinkDialog(url);
        }

        function createOpenLinkDialog(url) {
            pageStack.push(Qt.resolvedUrl("OpenLinkDialog.qml"), {url: url});
        }

        function createSelectionDialog(titleText, model, selectedIndex, onAccepted) {
            var p = {titleText: titleText, model: model, selectedIndex: selectedIndex}
            var dialog = pageStack.push(Qt.resolvedUrl("SelectionDialog.qml"), p);
            dialog.accepted.connect(function() { onAccepted(dialog.selectedIndex); })
        }
    }

    Constant { id: constant }
    AppSettings { id: appSettings }

    QuickdditManager {
        id: quickdditManager
        settings: appSettings
        onAccessTokenFailure: infoBanner.alert(errorString);
    }
}
