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

import QtQuick 1.1
import Quickddit.Core 1.0

QtObject {
    id: constant

    property color colorLight: theme.inverted ? "#ffffff" : "#191919"
    property color colorMid: theme.inverted ? "#8c8c8c" : "#666666"
    property color colorDisabled: theme.inverted ? "#444444" : "#b2b2b4"

    property color colorLikes: "#FF8B60"
    property color colorDislikes: "#9494FF"

    property int paddingSmall: 4
    property int paddingMedium: 8
    property int paddingLarge: 12
    property int paddingXLarge: 16

    property int fontSizeXSmall: 20
    property int fontSizeSmall: 22
    property int fontSizeMedium: 24
    property int fontSizeLarge: 26
    property int fontSizeXLarge: 28
    property int fontSizeXXLarge: 32

    property int fontSizeDefault: __fontSizeDefaultF()

    function __fontSizeDefaultF() {
        switch (appSettings.fontSize) {
        case AppSettings.SmallFontSize: return constant.fontSizeSmall;
        case AppSettings.MediumFontSize: return constant.fontSizeMedium;
        case AppSettings.LargeFontSize: return constant.fontSizeLarge;
        }
    }

    property int headerHeight: inPortrait ? 72 : 56

    // Quickddit specific
    property int commentRepliesIndentWidth: 16
    property variant commentRepliesColor: ["green", "orange", "purple", "yellow",
                                           "royalblue", "pink", "indigo", "gold",
                                           "red", colorLight];
}
