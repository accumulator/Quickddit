/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import quickddit.Core 1.0
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12
import io.thp.pyotherside 1.5

import "Qml"
import "Qml/Pages"

ApplicationWindow {
    id:window
    title: "Quickddit"
    visible: true
    width: 400
    height: 800

    SubredditsDrawer {
        id:subredditsDrawer
    }

    ToolTip {
        id:infoBanner
        x:parent.width/2-width/2
        y:parent.height-150

        function alert(txt) {
            infoBanner.timeout=3000
            infoBanner.text=txt
            infoBanner.visible=true
        }

        function warning(txt) {
            infoBanner.timeout=5000
            infoBanner.text=txt
            infoBanner.visible=true
        }
    }

    ToolBar{
        id:tBar
        visible: window.visibility !==Window.FullScreen
        height: 52
        background: Rectangle { color: persistantSettings.primaryColor }
        RowLayout {
            anchors.fill: parent

            ToolButton {
                visible: pageStack.depth>1
                icon.name: "go-previous-symbolic"
                onClicked: pageStack.pop()
            }

            ToolButton {
                visible: pageStack.depth<=1
                icon.name: "open-menu-symbolic"
                onClicked: subredditsDrawer.open()
            }

            Label {
                id:titleLabel
                font.pointSize: 14
                font.weight: Font.Normal
                elide: "ElideRight"
                Layout.fillWidth: true
                horizontalAlignment: "AlignLeft"
                verticalAlignment: "AlignVCenter"
                text: pageStack.currentItem.title
            }

            Loader {
                id:headerIcons
                height: parent.height
            }

            ToolButton {
                id:menu
                Layout.alignment: Qt.AlignRight
                visible: pageStack.depth<=1
                icon.name: "view-more-symbolic"
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    y:parent.y+parent.height
                    transformOrigin: Menu.TopRight

                    MenuItem {
                        text: qsTr("My Subreddits")
                        icon.name: "view-list-symbolic"
                        onTriggered: {pageStack.push(Qt.resolvedUrl("Qml/Pages/SubredditsPage.qml"))
                        }
                    }

                    MenuSeparator {topPadding: 0; bottomPadding: 0 }
                    
                    MenuItem {
                        text: qsTr("Messages")
                        icon.name: "mail-unread-symbolic" // TODO: icon.name: "mail-read-symbolic"
                        enabled: quickdditManager.isSignedIn
                        onTriggered: {pageStack.push(Qt.resolvedUrl("Qml/Pages/MessagePage.qml"))
                        }
                    }

                    MenuSeparator {topPadding: 0; bottomPadding: 0 }

                    MenuItem {
                        text:  qsTr("My profile")
                        icon.name: "avatar-default-symbolic"
                        enabled: quickdditManager.isSignedIn
                        onTriggered: { pageStack.push(Qt.resolvedUrl("Qml/Pages/UserPage.qml"),{username: appSettings.redditUsername}) }
                    }

                    MenuSeparator {topPadding: 0; bottomPadding: 0 }

                    MenuItem {
                        text: quickdditManager.isSignedIn ? qsTr("Log out")+" "+appSettings.redditUsername: qsTr("Log in")
                        icon.name: quickdditManager.isSignedIn ? "system-shutdown-symbolic" : "contact-new-symbolic"
                        onTriggered:{
                            !quickdditManager.isSignedIn ? pageStack.push(Qt.resolvedUrl("Qml/Pages/LoginPage.qml")) : logOutDialog.open();
                        }
                        Dialog{
                            id:logOutDialog
                            title: qsTr("Log out")
                            modal: true
                            standardButtons: Dialog.Yes | Dialog.No

                            Label {
                                text: qsTr("Do you want to log out?")
                            }
                            onAccepted: {
                                quickdditManager.signOut();
                                globalUtils.getMainPage().refresh();
                            }
                        }
                    }

                    MenuSeparator { topPadding: 0; bottomPadding: 0 }

                    MenuItem {
                        text: qsTr("Settings")
                        icon.name: "document-properties-symbolic"
                        onTriggered: pageStack.push(Qt.resolvedUrl("Qml/Pages/SettingsPage.qml"))
                    }

                    MenuSeparator { topPadding: 0; bottomPadding: 0 }

                    MenuItem {
                        text: qsTr("About")
                        icon.name: "help-about-symbolic"
                        onTriggered: pageStack.push(Qt.resolvedUrl("Qml/Pages/AboutPage.qml"))
                    }
                }
            }
        }
        Component.onCompleted: {
            persistantSettings.toolbarOnBottom ? footer = tBar : header = tBar
        }
    }

    StackView{
        id:pageStack
        anchors.fill: parent
        initialItem: Component{MainPage{}}
        onCurrentItemChanged: {
            headerIcons.sourceComponent = pageStack.currentItem.getButtons ? pageStack.currentItem.getButtons() : null
        }
    }

    AppSettings { id: appSettings }

    Settings {
        id: persistantSettings
        property real scale: 1.0

        property bool linksInternaly: true
        property bool enableNSFW: false
        property bool compactImages: false
        property bool compactVideos: true
        property bool fullResolutionImages: false
        property bool toolbarOnBottom: false
        onToolbarOnBottomChanged: {
            toolbarOnBottom? header = null : footer = null
            toolbarOnBottom? footer = tBar : header = tBar
        }
        property string style
        property string theme: "System"
        onThemeChanged: loadTheme()

        onStyleChanged: loadTheme()

        property color redColor: style==="Material" ? Material.color(Material.Red) : style==="Universal" ? Universal.color(Universal.Red): "#FFc7162b"
        property color greenColor: style==="Material" ? Material.color(Material.Green) : style==="Universal" ? Universal.color(Universal.Green) : "#FF0e8420"
        property color primaryColor
        property color textColor: titleLabel.color
    }

    Component.onCompleted: loadTheme()

    function loadTheme() {
        if (persistantSettings.theme === "Dark") {
            Material.theme = Material.Dark
            Universal.theme = Universal.Dark
        }
        else if (persistantSettings.theme === "Light") {
            Material.theme = Material.Light
            Universal.theme = Universal.Light
        }
        else if (persistantSettings.theme === "System") {
            Material.theme = Material.System
            Universal.theme = Universal.System
        }
        persistantSettings.primaryColor = persistantSettings.style == "Suru" ? "#e95420" : titleLabel.linkColor
    }

    QuickdditManager {
        id: quickdditManager
        settings: appSettings
        onAccessTokenFailure: {
            if (code == 299 /* QNetworkReply::UnknownContentError */) {
                infoBanner.warning(qsTr("Please log in again"));
                pageStack.push(Qt.resolvedUrl("Qml/Pages/AppSettingsPage.qml"));
            } else {
                infoBanner.warning(errorString);
            }
        }
        onAccessTokenSuccess: {
            infoBanner.alert(qsTr("Logged in succesfully"));
        }
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
            else if (/^(https?:\/\/(\w+\.)?reddit.com)?\/gallery\//.test(url))
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
                pushOrReplace(Qt.resolvedUrl("Qml/Pages/CommentPage.qml"), {linkPermalink: url});
            else if (/^\/r\/(\w+)/.test(redditLink.path)) {
                var path = redditLink.path.split("/");
                params["subreddit"] = path[2];
                if (path[3] === "search") {
                    if (redditLink.queryMap["q"] !== undefined)
                        params["query"] = redditLink.queryMap["q"]
                    pushOrReplace(Qt.resolvedUrl("SearchDialog.qml"), params);
                    return;
                }

                if (path[3] !== "")
                    params["section"] = path[3];
                //changed
                pushToMainPage(params)
            } else if (/^\/u(ser)?\/([A-Za-z0-9_-]+)/.test(redditLink.path)) {
                var username = redditLink.path.split("/")[2];
                //test
                pushOrReplace(Qt.resolvedUrl("Qml/Pages/UserPage.qml"), {username: username});
            } else if (/^\/message\/compose/.test(redditLink.path)) {
                params["recipient"] = redditLink.queryMap["to"]
                if (redditLink.queryMap["message"] !== null)
                    params["message"] = redditLink.queryMap["message"]
                if (redditLink.queryMap["subject"] !== null)
                    params["subject"] = redditLink.queryMap["subject"]
                pushOrReplace(Qt.resolvedUrl("Qml/Pages/SendMessagePage.qml"), params);
            } else if (/^\/search/.test(redditLink.path)) {
                if (redditLink.queryMap["q"] !== undefined)
                    params["query"] = redditLink.queryMap["q"]
                pushOrReplace(Qt.resolvedUrl("SearchDialog.qml"), params);
            } else
                infoBanner.alert(qsTr("Unsupported reddit url"));
        }

        function pushToMainPage(params) {
            pageStack.pop(getMainPage())
            if(params["section"])
                getMainPage().section=params["section"]
            getMainPage().refresh(params["subreddit"])
        }

        function pushOrReplace(page, params) {
            pageStack.push(page, params)
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
                pageStack.push(Qt.resolvedUrl("Qml/Pages/ImageViewPage.qml"), {imgurUrl: url});
            else if (/^https?:\/\/\S+\.(jpe?g|png|gif)/i.test(url))
                pageStack.push(Qt.resolvedUrl("Qml/Pages/ImageViewPage.qml"), {imageUrl: url});
            else if (/^https?:\/\/i.reddituploads.com\//.test(url))
                pageStack.push(Qt.resolvedUrl("Qml/Pages/ImageViewPage.qml"), {imageUrl: url});
            else
                infoBanner.alert(qsTr("Unsupported image url"));
        }

        function openVideoViewPage(url) {
            if (python.isUrlSupported(url)) {
                pageStack.push(Qt.resolvedUrl("Qml/Pages/VideoViewPage.qml"), { origUrl: url });
            } else if ((/^https?:\/\/\S+\.(mp4|avi|mkv|webm)/i.test(url))) {
                pageStack.push(Qt.resolvedUrl("Qml/Pages/VideoViewPage.qml"), { videoUrl: url });
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
            if(persistantSettings.linksInternaly)
                pageStack.push(Qt.resolvedUrl("Qml/Pages/WebViewer.qml"), {url: url, source: source});
            else
                Qt.openUrlExternally(url)
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

    Python {
        id: python

        signal videoInfo
        signal fail(string reason)

        property variant info

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('Qml/'));

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
            // TODO: now simply matches url against our own simple list. We should query YTDL itself.
            //console.log("testing ytdl support for url " + url)
            if (/^https?:\/\/((www|m)\.)?youtube\.com\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/((www|m)\.)?youtu\.be\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/((www)\.)?streamable\.com\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/((www)\.)?livestream\.com\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/my\.mixtape\.moe\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/(.+\.)?twitch.tv\/.+/.test(url)) {
                return true;
                //            } else if (/^https?:\/\/((www)\.)?vimeo.com\/.+/.test(url)) {
                //                return true;
            } else if (/^https?:\/\/(www\.)?gfycat\.com\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/((i|m)\.)?imgur\.com\/.+\.gifv$/.test(url)) {
                return true;
            } else if (/^https?:\/\/v\.redd\.it\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/(www\.)?pornhub\.com\/view_video\.php.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/(www\.)?hooktube\.com\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/(www\.)?dailymotion\.com\/.+/.test(url)) {
                return true;
            } else if (/^https?:\/\/(www\.)?bitchute\.com\/.+/.test(url)) {
                return true;
            } else {
                return false;
            }
        }

        onError: {
            console.log('python error: ' + traceback);
        }

        onReceived: {
            // asychronous messages from Python arrive here. if not explicitly handled
            console.log('got message from python: ' + data);
        }
    }
}
