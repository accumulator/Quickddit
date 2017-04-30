/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2017  Sander van Grieken

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
import QtMultimedia 5.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: videoViewPage
    title: qsTr("Video")

    property string videoUrl
    property string origUrl

    property bool error: false

    SilicaFlickable {
        id: videoFlickable
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom }

        PullDownMenu {
            MenuItem {
                text: qsTr("URL")
                onClicked: globalUtils.createOpenLinkDialog(origUrl || videoUrl);
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                playPauseButton.opacity = 1
                if (mediaPlayer.playbackState == MediaPlayer.PlayingState)
                    hideTimer.restart()
            }
        }

        VideoOutput {
            anchors.fill: parent

            source: MediaPlayer {
                id: mediaPlayer
                autoPlay: false
                onStopped: playPauseButton.opacity = 1
                onError: {
                    infoBanner.warning(errorString);
                    console.log(errorString);
                }

                onBufferProgressChanged: {
                    if (bufferProgress > 0.95)
                        play();
                    else if (bufferProgress < 0.05)
                        pause();
                }

                onSourceChanged: console.log("media player source url: " + url)
            }

            Item {
                id: spinner
                anchors.centerIn: parent

                width: busyIndicator.width
                height: busyIndicator.height
                visible: mediaPlayer.bufferProgress < 1 && mediaPlayer.error === MediaPlayer.NoError && !error

                BusyIndicator {
                    id: busyIndicator
                    size: BusyIndicatorSize.Large
                    running: true
                }

                Label {
                    anchors.centerIn: parent
                    font.pixelSize: constant.fontSizeSmall
                    text: Math.round(mediaPlayer.bufferProgress * 100) + "%"
                }
            }

            Label {
                id: errorText
                anchors.centerIn: parent
                visible: mediaPlayer.error !== MediaPlayer.NoError || error
                text: qsTr("Error loading video")
            }
        }

        Slider {
            id: progressBar
            enabled: mediaPlayer.seekable && opacity > 0
            opacity: playPauseButton.opacity
            anchors {
                left: parent.left
                bottom: parent.bottom
                right: parent.right
            }
            maximumValue: mediaPlayer.duration > 0 ? mediaPlayer.duration : 1
            value: mediaPlayer.position
            onReleased: {
                mediaPlayer.seek(value)
                value = Qt.binding(function() { return mediaPlayer.position; })
                playPauseButton.opacity = 1
                hideTimer.restart()
            }
        }

        Image {
            id: playPauseButton
            source: "image://theme/icon-l-" + (mediaPlayer.playbackState === MediaPlayer.PlayingState ? "pause" : "play")

            anchors {
                bottom: progressBar.top
                horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                anchors.fill: parent
                enabled: playPauseButton.opacity > 0
                onClicked: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause()
                        hideTimer.stop()
                        playPauseButton.opacity = 1
                    } else if (mediaPlayer.playbackState === MediaPlayer.PausedState || mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                        mediaPlayer.play()
                        hideTimer.start()
                    }
                }
            }
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    Component.onCompleted: {
        if (videoUrl === "") {
            // resolve with youtube-dl
            console.log("only origUrl set, resolving with youtube-dl...")
            python.requestVideoUrlFor(origUrl)
        } else {
            mediaPlayer.source = videoUrl
        }
    }

    Timer {
        id: hideTimer
        running: true
        interval: 1500
        onTriggered: {
            playPauseButton.opacity = 0
        }
    }

    Connections {
        target: python
        onVideoInfo: {
            var format
            var i
            var formats = python.info["_type"] === "playlist" ? python.info["entries"][0]["formats"] : python.info["formats"]
            console.log("checking on format_id")
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                // mp4-mobile: 360p,streamable.com
                // 18: 360p,mp4,acodec mp4a.40.2,vcodec avc1.42001E
                // 22: 720p,mp4,acodec mp4a.40.2,vcodec avc1.64001F
                if (~["mp4-mobile","18"].indexOf(format["format_id"])) {
                    console.log("format selected: " + format["format_id"])
                    mediaPlayer.source = format["url"]
                    return;
                }
            }
            console.log("not found. checking on ext=mp4 & height=360|480")
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                if (~["mp4"].indexOf(format["ext"]) && ~[360,480].indexOf(format["height"])) {
                    console.log("format selected: " + format["format_id"])
                    mediaPlayer.source = format["url"]
                    return;
                }
            }
            console.log("not found. checking on ext=mp4 & height=720")
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                if (~["mp4"].indexOf(format["ext"]) && ~[720].indexOf(format["height"])) {
                    console.log("format selected: " + format["format_id"])
                    mediaPlayer.source = format["url"]
                    return;
                }
            }
            console.log("not found. checking on ext=mp4")
            for (i = 0; i < formats.length; i++) {
                format = formats[i]
                if (~["mp4"].indexOf(format["ext"])) {
                    console.log("format selected: " + format["format_id"])
                    mediaPlayer.source = format["url"]
                    return;
                }
            }
            console.log("not found. fallback: selecting first format")
            var url = formats[0]["url"]
            mediaPlayer.source = url
        }

        onError: {
            error = true
            infoBanner.warning(qsTr("Problem finding stream URL"));
        }

    }

    DisplayBlanking {
        preventBlanking: (mediaPlayer.playbackState !== MediaPlayer.StoppedState && mediaPlayer.playbackState !== MediaPlayer.PausedState)
    }
}
