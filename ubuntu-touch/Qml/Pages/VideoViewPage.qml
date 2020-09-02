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

import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import QtMultimedia 5.9
import QtWebEngine 1.9

Page {
    id: videoViewPage
    title: qsTr("Video")

    property string videoUrl
    property string origUrl
    property string playerUrl : "qrc:/videoPlayer.html?videoSrc="

    property bool error: false

    WebEngineView{
        anchors.fill: parent
        id:webView
        settings.localContentCanAccessFileUrls: true
        settings.localContentCanAccessRemoteUrls: true
        settings.allowRunningInsecureContent: true
    }


    Component.onCompleted: {
        if (videoUrl === "") {
            // resolve with youtube-dl
            console.log("only origUrl set, resolving with youtube-dl...")
            python.requestVideoUrlFor(origUrl)
        } else {
            webView.url = videoUrl
        }
    }

    Connections {
        target: python
        onVideoInfo: {
            var urls = {}
            var format
            var i
            var formats = python.info["_type"] === "playlist" ? python.info["entries"][0]["formats"] : python.info["formats"]
            if (formats === undefined)
                fail(qsTr("Problem finding stream URL"))
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                if (~["mp4"].indexOf(format["ext"]) && ~[360,480].indexOf(format["height"])) {
                    console.log("format selected by ext " + format["ext"] + " and height " + format["height"])
                    urls["360"] = format["url"]
                }
            }
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                if (~["mp4"].indexOf(format["ext"]) && ~[720].indexOf(format["height"])) {
                    console.log("format selected by ext " + format["ext"] + " and height " + format["height"])
                    urls["720"] = format["url"]
                }
            }
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                // selection by format_id for youtube, vimeo, streamable
                // mp4-mobile: 360p (streamable.com)
                // 18: 360p,mp4,acodec mp4a.40.2,vcodec avc1.42001E (youtube)
                // 22: 720p,mp4,acodec mp4a.40.2,vcodec avc1.64001F (youtube)
                // http-360p: 360p (vimeo)
                // http-720p, 720p (vimeo)
                if (~["mp4-mobile","18","http-360p"].indexOf(format["format_id"])) {
                    console.log("format selected by id " + format["format_id"])
                    urls["360"] = format["url"]
                }
                if (~["22","http-720p"].indexOf(format["format_id"])) {
                    console.log("format selected by id " + format["format_id"])
                    urls["720"] = format["url"]
                }
            }
            if (python.info["extractor"].indexOf("Reddit") === 0)
                for (i = 0; i < formats.length; i++) {
                    format = formats[i]
                    // selection by height if format_id is like hls-*, for v.redd.it (with 'deref' HLS stream by string replace, so only works for v.redd.it)
                    if (format["format_id"].indexOf("hls-") !== 0)
                        continue
                    if (format["height"] === undefined) // audio
                        continue
                    // acodec none,vcodec one of avc1.4d001f,avc1.4d001e,avc1.42001e
                    if (format["height"] <= 480) {
                        console.log("format selected by id " + format["format_id"] + " and height <= 480")
                        urls["360"] = format["url"].replace("dsasda.m3u8",".ts")  // 'deref' by string replace
                    } else {
                        console.log("format selected by id " + format["format_id"] + " and height > 480")
                        urls["720"] = format["url"].replace("sadsda.m3u8",".ts")  // 'deref' by string replace
                    }
                }
            if (urls["360"] === undefined && urls["720"] === undefined) {
                console.log("fallback, checking on ext=mp4")
                for (i = 0; i < formats.length; i++) {
                    format = formats[i]
                    if (~["mp4"].indexOf(format["ext"])) {
                        console.log("format selected: " + format["format_id"])
                        urls["other"] = format["url"]
                    }
                }
                if (urls["other"] === undefined)
                    urls["other"] = formats[0]["url"]
            }

            if (appSettings.preferredVideoSize === AppSettings.VS360) {
                if (urls["360"] === undefined)
                    console.log("360p selected but fallback to 720p")
                webView.url = urls["360"] !== undefined ? urls["360"] : urls["720"] !== undefined ? urls["720"] : urls["other"]
            } else {
                if (urls["720"] === undefined)
                    console.log("720p selected but fallback to 360p")
                webView.url = urls["720"] !== undefined ? urls["720"] : urls["360"] !== undefined ? urls["360"] : urls["other"]
            }

            if (webView.url === undefined)
                fail(qsTr("Problem finding stream URL"))
        }

        onError: {
            error = true
            console.log(reason);
            infoBanner.warning(qsTr("youtube-dl error: %1").arg(traceback));
        }

        onFail: {
            error = true
            console.log(reason);
            infoBanner.warning(reason);
        }

    }
}
