import QtQuick 2.0
import Quickddit 1.0
import Sailfish.Silica 1.0

QtObject {
    id: constant

    readonly property color colorLight: Theme.primaryColor
    readonly property color colorMid: Theme.secondaryColor
    readonly property color colorDisabled: Qt.darker(colorMid, 1.5)

    readonly property color colorPositive: "green"
    readonly property color colorNegative: "red"
    readonly property color colorNeutral: "darkgray"

    readonly property int paddingSmall: Theme.paddingSmall
    readonly property int paddingMedium: Theme.paddingMedium
    readonly property int paddingLarge: Theme.paddingLarge
    readonly property int paddingXLarge: paddingLarge + paddingSmall

    readonly property int fontSizeXSmall: Theme.fontSizeExtraSmall
    readonly property int fontSizeSmall: Theme.fontSizeSmall
    readonly property int fontSizeMedium: Theme.fontSizeMedium
    readonly property int fontSizeLarge: Theme.fontSizeLarge
    readonly property int fontSizeXLarge: Theme.fontSizeExtraLarge
    readonly property int fontSizeXXLarge: Theme.fontSizeHuge

    property int fontSizeDefault: __fontSizeDefaultF()

    function __fontSizeDefaultF() {
        switch (appSettings.fontSize) {
        case AppSettings.SmallFontSize: return constant.fontSizeSmall;
        case AppSettings.MediumFontSize: return constant.fontSizeMedium;
        case AppSettings.LargeFontSize: return constant.fontSizeLarge;
        }
    }

    // Quickddit specific
    readonly property int commentRepliesIndentWidth: 20
    readonly property variant commentRepliesColor: ["green", "orange", "purple", "yellow",
                                                    "royalblue", "pink", "indigo", "gold",
                                                    "red", colorLight];
}
