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
import harbour.quickddit.Core 1.0
import Sailfish.Silica 1.0

QtObject {
    id: constant

    readonly property color colorLight: Theme.primaryColor
    readonly property color colorMid: Theme.secondaryColor
    readonly property color colorDisabled: Theme.colorScheme ? Qt.lighter(colorMid, 1.5) : Qt.darker(colorMid, 1.5)
    readonly property color colorMidLight: Theme.colorScheme ? Qt.lighter(colorLight, 1.2) : Qt.darker(colorLight, 1.2)
    readonly property color colorHi: Theme.colorScheme ? Qt.darker(Theme.highlightColor, 1.1) : Qt.lighter(Theme.highlightColor, 1.1)

    property color colorLikes: "#FF8B60"
    property color colorDislikes: "#9494FF"

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
    property int fontSizeSmaller: __fontSizeSmallerF()
    property int fontSizeLarger: __fontSizeLargerF()
    property int orientationSetting: __orientationSettingF()

    property string richtextStyle: contentStyle(true)

    function contentStyle(enabled) {
        return "<style>del {text-decoration: line-through;} h1 { font-size: x-large; } " +
               "table { font-family: monospace; font-size: small; } thead { text-decoration: underline ; } td { padding-right: 20px; } " +
               "a { color: " + (enabled ? Theme.highlightColor : colorDisabled) + "; } " +
               "code { color: " + (enabled ? colorHi : colorDisabled) + "; } </style>"
    }

    function __fontSizeDefaultF() {
        switch (appSettings.fontSize) {
        case AppSettings.TinyFontSize: return constant.fontSizeXSmall;
        case AppSettings.SmallFontSize: return constant.fontSizeSmall;
        case AppSettings.MediumFontSize: return constant.fontSizeMedium;
        case AppSettings.LargeFontSize: return constant.fontSizeLarge;
        }
    }

    function __fontSizeSmallerF() {
        switch (appSettings.fontSize) {
        case AppSettings.TinyFontSize: return constant.fontSizeXSmall - 1;
        case AppSettings.SmallFontSize: return constant.fontSizeXSmall;
        case AppSettings.MediumFontSize: return constant.fontSizeSmall;
        case AppSettings.LargeFontSize: return constant.fontSizeMedium;
        }
    }

    function __fontSizeLargerF() {
        switch (appSettings.fontSize) {
        case AppSettings.TinyFontSize: return constant.fontSizeSmall;
        case AppSettings.SmallFontSize: return constant.fontSizeMedium;
        case AppSettings.MediumFontSize: return constant.fontSizeLarge;
        case AppSettings.LargeFontSize: return constant.fontSizeXLarge;
        }
    }

    function __orientationSettingF() {
        switch (appSettings.orientationProfile) {
        case AppSettings.DynamicProfile: return Orientation.All;
        case AppSettings.PortraitOnlyProfile: return Orientation.Portrait;
        case AppSettings.LandscapeOnlyProfile: return Orientation.Landscape;
        }
    }

    // Quickddit specific
    readonly property int commentRepliesIndentWidth: 4 + 8 * QMLUtils.pScale
    readonly property variant commentRepliesColor: ["#9B30FF", "yellow", "green", "royalblue",
                                                    "orange", "pink", "#836FFF", "gold",
                                                    "red", colorLight];

}
