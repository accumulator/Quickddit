import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0

ItemDelegate {
    id:subredditDelegate

    property variant manager
    width: parent.width
    height: Math.max(ico.height+10,titleText.height + fullText.height+20)
    Image {
        id:ico
        width: 64
        height: 64
        source:model.iconUrl
        anchors{left: parent.left; top: parent.top;margins: 5}
        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource: Rectangle{
                width: 64
                height: width
                radius: width
            }
        }
    }

    Label {
        id:titleText
        anchors{left: ico.right;right: parent.right;top: parent.top;margins: 5}
        elide: "ElideRight"
        text: "/r/"+model.displayName+" ("+model.title+")"
        font.bold: true
    }

    Label {
        id:fullText
        anchors{top: titleText.bottom;left: ico.right;right: parent.right;margins: 5}
        text: model.shortDescription
        wrapMode: "Wrap"
        elide: "ElideRight"
        maximumLineCount: 3
    }
}
