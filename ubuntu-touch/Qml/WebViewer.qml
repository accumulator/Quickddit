import QtQuick 2.9
import QtWebEngine 1.7
import QtQuick.Controls 2.2
Page {
    title: webView.title
    property url url

    WebEngineView{
        anchors.fill: parent
        id:webView
    }

    Component.onCompleted: {
        webView.url = url;
    }
}
