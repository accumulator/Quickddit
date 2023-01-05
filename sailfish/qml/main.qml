/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2015-2017  Sander van Grieken

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

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.5
import harbour.quickddit.Core 1.0

ApplicationWindow {
    id: appWindow
    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml");

    Python {
        id: python

        signal videoInfo
        signal fail(string reason)

        property variant info

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'));
            addImportPath(Qt.resolvedUrl('..'));

            setHandler('log', function(msg) {
                console.log('python: ' + msg)
            })

            setHandler('fail', function(msg) {
                console.log('fail signal: ' + msg)
                fail(msg)
            })

            importModule('ytdl_wrapper', function() {})
        }

        function requestVideoUrlFor(url) {
            console.log("video url requested " + url)
            call('ytdl_wrapper.retrieveVideoInfo', [url.toString()], function(result) {
                if (result === undefined) {
                    return;
                }

                console.log(JSON.stringify(result,null,4))
                info = result
                videoInfo()
            })
        }

        function isUrlSupported(url) {
            //console.log("testing ytdl support for url " + url)
            return call_sync('ytdl_wrapper.isVideoUrlSupported', [url.toString()] )
        }

        onError: {
            console.log('python error: ' + traceback);
        }

        onReceived: {
            // asychronous messages from Python arrive here. if not explicitly handled
            console.log('got message from python: ' + data);
        }
    }

    // Global busy indicator, it reads the 'busy' property from the current page
    DockedPanel {
        id: busyPanel
        width: parent.width
        height: busyIndicator.height + 2 * constant.paddingLarge
        open: pageStack.currentPage.hasOwnProperty('busy') ? pageStack.currentPage.busy : false
        dock: Dock.Bottom
        enabled: false

        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
            running: busyPanel.open
        }
    }

    DockedPanel {
        id: clipboardNotifier
        width: parent.width
        height: contentRow.height + constant.paddingMedium
        open: false
        dock: Dock.Bottom

        Row {
            id: contentRow
            width: parent.width
            anchors.centerIn: parent

            Rectangle {
                height: 1
                width: contentRow.spacing
            }

            IconButton {
                icon.source: "image://theme/icon-m-clipboard"
                scale: 0.8
                highlighted: true
            }

            Label {
                text: globalUtils.parseRedditLink(QMLUtils.clipboardText).path.slice(1)
                width: parent.width - 3 * goButton.width + 6 * contentRow.spacing
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
            }

            IconButton {
                id: goButton
                icon.source: "image://theme/icon-m-forward"
                onClicked: {
                    if (globalUtils.redditLink(QMLUtils.clipboardText)) {
                        clipboardNotifier.hide();
                        globalUtils.openRedditLink(QMLUtils.clipboardText);
                    }
                }
            }

            IconButton {
                icon.source: "image://theme/icon-m-close"
                onClicked: clipboardNotifier.hide()
            }
        }
    }

    bottomMargin: clipboardNotifier.expanded ? clipboardNotifier.visibleSize : 0

    // work around ugly animation of DockedPanels when orientation changes to portrait
    onOrientationChanged: {
        busyPanel._initialized = false
        clipboardNotifier._initialized = false
    }

    // reset inbox poll timer when activating the application
    onApplicationActiveChanged: if (applicationActive) inboxManager.resetTimer();

    InfoBanner { id: infoBanner }

    property QtObject webViewPage: null
    property Component __webViewPage: Component {
        WebViewer {}
    }

    property QtObject subredditsPage
    property Component __subredditsPage: Component {
        SubredditsPage {}
    }

    // A collections of global utility functions
    QtObject {
        id: globalUtils

        property Component __openLinkDialogComponent: null

        function getMainPage() {
            return pageStack.find(function(page) { return page.objectName === "mainPage"; });
        }

        function getWebViewPage() {
            if (webViewPage === null) {
                webViewPage = __webViewPage.createObject(appWindow);
            }
            return webViewPage;
        }

        function getNavPage() {
            if (subredditsPage == undefined) {
                subredditsPage = __subredditsPage.createObject(appWindow);
            }
            return subredditsPage;
        }

        function getMultiredditModel() {
            return getNavPage().getMultiredditModel()
        }

        function previewableVideo(url) {
            if (python.isUrlSupported(url)) {
                return true;
            } else if (/^https?:\/\/\S+\.(mp4|avi|mkv|webm)/i.test(url)) {
                return true
            } else {
                return false
            }
        }

        function previewableImage(url) {
            // imgur url
            if (/^https?:\/\/((i|m|www)\.)?imgur\.com\//.test(url))
                return !(/^.*\.gifv$/.test(url));
            // reddituploads
            else if (/^https?:\/\/i.reddituploads.com\//.test(url))
                return true;
            if (/^(https?:\/\/(\w+\.)?reddit.com)?\/gallery\//.test(url))
                return true;
            // direct image url with image format extension
            else if (/^https?:\/\/\S+\.(jpe?g|png|gif)/i.test(url))
                return true;
            else
                return false;
        }

        function redditLink(url) {
            var redditLink = parseRedditLink(url);
            if (redditLink === null)
                return false;

            if (/\.rss$/.test(redditLink.path)) // don't handle RSS links in-app
                return false;
            if (/^\/r\/\w+\/wiki(\/\w+)?/.test(redditLink.path)) // don't handle /r/sub/wiki links in-app
                return false;

            if (/^(\/r\/\w+)?\/comments\/\w+/.test(redditLink.path))
                return true;
            if (/^\/r\/(\w+)/.test(redditLink.path))
                return true;
            if (/^\/u(ser)?\/([A-Za-z0-9_-]+)/.test(redditLink.path))
                return true;
            if (/^\/message\/compose/.test(redditLink.path))
                return true;
            if (/^\/search/.test(redditLink.path))
                return true;

            return false
        }

        function openRedditLink(url) {
            var redditLink = parseRedditLink(url);
            if (redditLink === null) {
                console.log("Not a reddit link: " + url);
                return;
            }

            var params = {}

            if (/^(\/r\/\w+)?\/comments\/\w+/.test(redditLink.path))
                pushOrReplace(Qt.resolvedUrl("CommentPage.qml"), {linkPermalink: url});
            else if (/^\/r\/(\w+)/.test(redditLink.path)) {
                var path = redditLink.path.split("/");
                params["subreddit"] = path[2];
                if (path[3] === "search") {
                    if (redditLink.queryMap["q"] !== undefined)
                        params["query"] = redditLink.queryMap["q"]
                    pushOrReplace(Qt.resolvedUrl("SearchDialog.qml"), params);
                    return;
                }

                if (path[3] !== undefined && path[3] !== "")
                    params["section"] = path[3];
                pushOrReplace(Qt.resolvedUrl("MainPage.qml"), params);
            } else if (/^\/u(ser)?\/([A-Za-z0-9_-]+)/.test(redditLink.path)) {
                var username = redditLink.path.split("/")[2];
                pushOrReplace(Qt.resolvedUrl("UserPage.qml"), {username: username});
            } else if (/^\/message\/compose/.test(redditLink.path)) {
                params["recipient"] = redditLink.queryMap["to"]
                if (redditLink.queryMap["message"] !== null)
                    params["message"] = redditLink.queryMap["message"]
                if (redditLink.queryMap["subject"] !== null)
                    params["subject"] = redditLink.queryMap["subject"]
                pushOrReplace(Qt.resolvedUrl("SendMessagePage.qml"), params);
            } else if (/^\/search/.test(redditLink.path)) {
                if (redditLink.queryMap["q"] !== undefined)
                    params["query"] = redditLink.queryMap["q"]
                pushOrReplace(Qt.resolvedUrl("SearchDialog.qml"), params);
            } else
                infoBanner.alert(qsTr("Unsupported reddit url"));
        }

        function pushOrReplace(page, params) {
            if (pageStack.currentPage.objectName === "subredditsPage") {
                var mainPage = globalUtils.getMainPage();
                mainPage.__pushedAttached = false;
                pageStack.replaceAbove(mainPage, page, params);
            } else {
                pageStack.push(page, params)
            }
        }

        function parseRedditLink(url) {
            var shortLinkRe = /^https?:\/\/redd.it\/([^/]+)\/?/.exec(url);
            var linkRe = /^(https?:\/\/(\w+\.)?reddit.com)?(\/[^?]*)(\?.*)?/.exec(url);
            if (linkRe === null && shortLinkRe === null) {
                return null;
            }

            var link = {}
            if (shortLinkRe !== null) {
                link = {
                    path: "/comments/" + shortLinkRe[1],
                    query: ""
                }
            } else {
                link = {
                    path: linkRe[3].charAt(linkRe[3].length-1) === "/" ? linkRe[3].substring(0,linkRe[3].length-1) : linkRe[3],
                    query: linkRe[4] === undefined ? "" : linkRe[4].substring(1)
                }
            }
            link.queryMap = {}
            if (link.query !== "") {
                var urlparams = link.query.split("&")
                for (var i=0; i < urlparams.length; i++) {
                    var kvp = urlparams[i].split("=");
                    link.queryMap[kvp[0]] = decodeURIComponent(kvp[1]);
                }
            }
            return link
        }

        function openImageViewPage(url) {
            if (/^https?:\/\/((i|m|www)\.)?imgur\.com/.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imgurUrl: url});
            else if (/^https?:\/\/\S+\.(jpe?g|png|gif)/i.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imageUrl: url});
            else if (/^https?:\/\/i.reddituploads.com\//.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {imageUrl: url});
            else if (/^(https?:\/\/(\w+\.)?reddit.com)?\/gallery\//.test(url))
                pageStack.push(Qt.resolvedUrl("ImageViewPage.qml"), {galleryUrl: url});
            else
                infoBanner.alert(qsTr("Unsupported image url"));
        }

        function openVideoViewPage(url) {
            if (python.isUrlSupported(url)) {
                pageStack.push(Qt.resolvedUrl("VideoViewPage.qml"), { origUrl: url });
            } else if ((/^https?:\/\/\S+\.(mp4|avi|mkv|webm)/i.test(url))) {
                pageStack.push(Qt.resolvedUrl("VideoViewPage.qml"), { videoUrl: url });
            } else
                infoBanner.alert(qsTr("Unsupported video url"));
        }

        function openLink(url) {
            url = QMLUtils.toAbsoluteUrl(url);
            if (!url)
                return;

            if (previewableVideo(url))
                openVideoViewPage(url);
            else if (previewableImage(url))
                openImageViewPage(url);
            else if (redditLink(url))
                openRedditLink(url);
            else
                createOpenLinkDialog(url);
        }

        function openNonPreviewLink(url, source) {
            url = QMLUtils.toAbsoluteUrl(url);
            if (url) {
                source = QMLUtils.toAbsoluteUrl(source);
                if (source === url) {
                    source = undefined
                }

                createOpenLinkDialog(url,source);
            }
        }

        function createOpenLinkDialog(url, source) {
            pageStack.push(Qt.resolvedUrl("OpenLinkDialog.qml"), {url: url, source: source});
        }

        function createSelectionDialog(title, model, selectedIndex, onAccepted) {
            var p = {title: title, model: model, selectedIndex: selectedIndex}
            var dialog = pageStack.push(Qt.resolvedUrl("SelectionDialog.qml"), p);
            dialog.accepted.connect(function() { onAccepted(dialog.selectedIndex); })
        }

        function formatDuration(seconds) {
            var date = new Date(null);
            if (seconds < 0)
                seconds = 0
            date.setSeconds(seconds);
            var durationString = date.toISOString().substr(11, 8);
            if (durationString.indexOf("00") === 0)
                durationString = durationString.substr(3)
            return durationString
        }

        // StyledText has severe limitations, but can be elided unlike RichText
        // we pick off a few <p> paragraphs and return a simplified, cropped representation
        function formatForStyledText(text) {
            var result = ""
            var re = /(<p>(.*?)<\/p>)/g
            re.lastIndex = 0 // QT bug, lastIndex not always initialized to 0
            var match = re.exec(text)
            while (result.length < 1000 && match !== null) {
                if (result.length != 0)
                    result += "<br/><br/>"
                result += match[2]
                console.log(result);
                match = re.exec(text)
            }
            if (result.length == 0)
                result = text
            result = result.replace(/&#39;/g,"'") // $#39 not shown when using StyledText?
            return result
        }
    }

    Constant { id: constant }
    Settings { id: settings }

    QuickdditManager {
        id: quickdditManager
        settings: settings
        onAccessTokenFailure: {
            if (code == 299 /* QNetworkReply::UnknownContentError */) {
                infoBanner.warning(qsTr("Please log in again"));
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
            } else {
                infoBanner.warning(errorString);
            }
        }
    }

    InboxManager {
        id: inboxManager
        manager: quickdditManager
        enabled: settings.pollUnread

        property bool hasUnseenUnread: false

        function dismiss() {
            hasUnseenUnread = false;
        }

        function publishReplies(messages) {
            var result = [];
            for (var i=0; i < messages.length; i++) {
                if (messages[i].isComment === true) {
                    result.push(messages[i]);
                }
            }
            if (result.length > 0)
                QMLUtils.publishNotification(
                        result[0].subject,
                        "in /r/" + result[0].subreddit + " by " + result[0].author
                            + (result.length === 1 ? "" : qsTr(" and %1 other").arg(result.length-1)),
                        result.length);
        }

        function publishMessages(messages) {
            for (var i=0; i < messages.length; i++) {
                if (messages[i].isComment === false) {
                    QMLUtils.publishNotification(
                            messages[i].author !== ""
                                ? qsTr("Message from %1").arg(messages[i].author)
                                : qsTr("Message from %1").arg("r/" + messages[i].subreddit),
                            messages[i].rawBody,
                            1);
                }
            }
        }

        onNewUnread: {
            if (appWindow.applicationActive) {
                infoBanner.alert(messages.length === 1
                                 ? qsTr("New message from %1").arg(messages[0].author)
                                 : qsTr("%n new messages", "0", messages.length));
            } else {
                publishReplies(messages);
                publishMessages(messages);
            }
            hasUnseenUnread = true;
        }

        onError: infoBanner.warning(error);
    }

    Connections {
        target: DbusApp
        onRequestMessageView: {
            if (pageStack.currentPage.objectName === "messagePage") {
                pageStack.currentPage.refresh();
            } else {
                pageStack.push(Qt.resolvedUrl("MessagePage.qml"));
            }

            appWindow.activate();
        }
        onRequestOpenURL: {
            if (globalUtils.redditLink(url)) {
                globalUtils.openRedditLink(url);
                appWindow.activate();
            }
        }
    }

    Connections {
        target: QMLUtils
        onClipboardChanged : {
            console.log("clip changed");
            if (globalUtils.redditLink(QMLUtils.clipboardText))
                clipboardNotifier.show()
        }
    }

}
