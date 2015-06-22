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
import com.nokia.extras 1.1
import Quickddit.Core 1.0

PageStackWindow {
    id: appWindow
    showStatusBar: inPortrait
    initialPage: Component { MainPage {} }

    InfoBanner {
        id: infoBanner
        topMargin: showStatusBar ? 40 : 8

        function alert(text) {
            infoBanner.text = text
            infoBanner.show()
        }
    }

    QtObject {
        id: globalUtils

        property Component __openLinkDialogComponent: null
        property Component __selectionDialogComponent: Component { SelectionDialog {} }
        property Component __listModelComponent: Component { ListModel {} }
        property Component __queryDialogCompnent: Component { QueryDialog {} }

        function previewableImage(url) {
            // imgur url
            if (/^https?:\/\/((i|m)\.)?imgur\.com/.test(url))
                return true;
            // direct image url with image format extension
            else if (/^https?:\/\/\S+\.(jpe?g|png|gif)/i.test(url))
                return true;
            else
                return false;
        }

        function openImageViewPage(url) {
            if (/^https?:\/\/((i|m)\.)?imgur\.com/.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imgurUrl: url});
            else if (/^https?:\/\/\S+\.(jpe?g|png|gif)/i.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imageUrl: url});
            else
                infoBanner.alert("Unsupported image url");
        }

        function openInTextLink(url) {
            url = QMLUtils.toAbsoluteUrl(url);
            if (!url)
                return;

            if (previewableImage(url))
                openImageViewPage(url);
            else if (/^https?:\/\/(\w+\.)?reddit.com(\/r\/\w+)?\/comments\/\w+/.test(url))
                pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: url});
            else
                createOpenLinkDialog(url);
        }

        function createOpenLinkDialog(url) {
            if (!__openLinkDialogComponent)
                __openLinkDialogComponent = Qt.createComponent("OpenLinkDialog.qml");
            var dialog = __openLinkDialogComponent.createObject(pageStack.currentPage, {url: url});
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed)
                    dialog.destroy(250);
            });
            dialog.open();
        }

        function createSelectionDialog(title, model, selectedIndex, onAccepted) {
            // convert array (model) to ListModel because SelectionDialog can not accept array
            var listModel = __listModelComponent.createObject(null);
            model.forEach(function(m) { listModel.append({ "text": m }) });

            var p = {titleText: title, model: listModel, selectedIndex: selectedIndex};
            var dialog = __selectionDialogComponent.createObject(pageStack.currentPage, p);
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed) {
                    dialog.destroy(250);
                    listModel.destroy();
                }
            });
            dialog.accepted.connect(function() { onAccepted(dialog.selectedIndex) });
            dialog.open();
        }

        function createQueryDialog(title, message, onAccepted) {
            var p = { titleText: title, message: message, acceptButtonText: "Yes", rejectButtonText: "No" };
            var dialog = __queryDialogCompnent.createObject(pageStack.currentPage, p);
            dialog.statusChanged.connect(function() {
                if (dialog.status == DialogStatus.Closed)
                    dialog.destroy(250);
            });
            dialog.accepted.connect(onAccepted);
            dialog.open();
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
        onAccessTokenFailure: {
            if (code == 299 /* QNetworkReply::UnknownContentError */) {
                infoBanner.alert("Please log in again");
                pageStack.push(Qt.resolvedUrl("AppSettingsPage.qml"));
            } else {
                infoBanner.alert(errorString);
            }
        }
    }
}
