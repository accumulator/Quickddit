import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

AbstractPage {
    id: videoViewPage
    title: "Video"

    property alias videoUrl: mediaPlayer.source

    MouseArea {
        anchors.fill: parent
        onClicked: {
            playPauseButton.opacity = 1
            hideTimer.restart()
        }
    }

    VideoOutput {
        anchors.fill: parent

        source: MediaPlayer {
            id: mediaPlayer
            autoPlay: true
            loops: MediaPlayer.Infinite
            onError: console.log(errorString)
        }

        Item {
            anchors.centerIn: parent

            width: busyIndicator.width
            height: busyIndicator.height
            visible: mediaPlayer.bufferProgress < 1

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
    }

    Slider {
        id: progressBar
        opacity: playPauseButton.opacity
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }
        maximumValue: mediaPlayer.duration
        value: mediaPlayer.position
        onClicked: {
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
            onClicked: {
                if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                    mediaPlayer.pause()
                    hideTimer.stop()
                    playPauseButton.opacity = 1
                } else if (mediaPlayer.playbackState === MediaPlayer.PausedState){
                    mediaPlayer.play()
                    hideTimer.start()
                }
            }
        }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Timer {
        id: hideTimer
        running: true
        interval: 1500
        onTriggered: {
            playPauseButton.opacity = 0
        }
    }
}
