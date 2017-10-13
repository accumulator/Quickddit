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
import Sailfish.Silica 1.0

// TODO: redesign cover page
CoverBackground {
    id: coverBackground

    Image {
        source: "./background.png"
        anchors {
            left: parent.left
            leftMargin: - (parent.width / 3)
            top: parent.top
            topMargin: - (parent.height / 4)

            right: parent.right
            rightMargin: (parent.width / 4)
            bottom: parent.bottom
            bottomMargin: (parent.height / 2)
        }
        fillMode: Image.PreserveAspectFit
        opacity: 0.2
    }

    CoverPlaceholder {
        text: pageStack.currentPage.title || ""
    }

}
