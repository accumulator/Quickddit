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
