/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2020  Daniel Kutka

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

import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import "../"
import "../Delegates"

Page {
    id: aboutMultiredditPage
    objectName: "multiredditPage"
    title: "/m/"+multiredditManager.name

    property alias multireddit: multiredditManager.name
    property alias  mrModel: multiredditManager.model

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: logo.height  + showButton.height + about.height //+ wiki.height
        ScrollBar.vertical.interactive: false

        CircleImage {
            id:logo
            source: multiredditManager.iconUrl
            anchors{left: parent.left;top:parent.top; leftMargin: 20}
            width: Math.min(150,parent.width/4)
            height: width
            Component.onCompleted: console.log(source)
        }

        Label {
            id:fullName
            text: multireddit
            font.pointSize: 18
            anchors{ left: logo.right;bottom: name.top;leftMargin: 20}
        }

        Label {
            id:name
            text: "m/"+multireddit
            anchors{left: logo.right;bottom: logo.bottom;leftMargin: 20}
        }

        Label {
            id:about
            anchors {left: parent.left;right: parent.right;top: name.bottom; margins:10}
            text: multiredditManager.description
            wrapMode: "WordWrap"
        }

        Button {
            id:showButton
            text: "Show posts in m/"+multireddit
            anchors { horizontalCenter: parent.horizontalCenter; top: about.bottom; margins: 10}
            onClicked: {
                globalUtils.getMainPage().refreshMR(multireddit)
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition)
            }
        }
    }

    AboutMultiredditManager {
        id: multiredditManager
        manager: quickdditManager
        onSuccess: infoBanner.alert(message);
        onError: infoBanner.warning(errorString);
    }
}
