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
import harbour.quickddit.Core 1.0

Dialog {
    id: multiredditDialog

    readonly property string title: "Multireddits"
    property alias multiredditModel: multiredditListView.model
    property string multiredditName

    canAccept: false

    SilicaListView {
        id: multiredditListView
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                enabled: !multiredditModel.busy
                text: "Refresh"
                onClicked: multiredditModel.refresh(false);
            }
        }

        header: DialogHeader { title: multiredditDialog.title }

        delegate: SimpleListItem {
            text: "/m/" + model.name
            onClicked: {
                multiredditDialog.multiredditName = model.name;
                canAccept = true;
                multiredditDialog.accept();
            }
        }

        footer: LoadingFooter { visible: multiredditModel.busy; listViewItem: multiredditListView }

        ViewPlaceholder { enabled: multiredditListView.count == 0 && !multiredditModel.busy; text: "Nothing here :(" }
    }
}
