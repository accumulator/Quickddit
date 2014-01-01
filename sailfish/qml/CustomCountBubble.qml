import QtQuick 2.0

Item {
    id: customCountBubble

    property int value
    property int colorMode: 0

    height: valueText.paintedHeight + 2 * constant.paddingSmall
    width: valueText.paintedWidth + 2 * constant.paddingMedium

    Rectangle {
        id: background
        anchors.fill: parent
        radius: constant.paddingLarge
        color: {
            if (colorMode > 0)
                return constant.colorPositive;
            else if (colorMode < 0)
                return constant.colorNegative;
            else
                return constant.colorNeutral;
        }
    }

    Text {
        id: valueText
        anchors.centerIn: parent
        font.pixelSize: constant.fontSizeSmall
        color: constant.colorLight
        text: customCountBubble.value
    }
}
