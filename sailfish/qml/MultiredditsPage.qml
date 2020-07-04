/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong
    Copyright (C) 2016  Sander van Grieken

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

AbstractPage {
    id: multiredditsPage

    readonly property string title: qsTr("Multireddits")
    property string multiredditName

    property MultiredditModel _model

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            if (_model.rowCount() === 0 && quickdditManager.isSignedIn)
                _model.refresh(false)
        }
    }

    signal accepted

    onAccepted: {
        var mainPage = globalUtils.getMainPage();
        mainPage.refreshMR(multiredditName);
        pageStack.pop(mainPage);
    }

    SilicaListView {
        id: multiredditListView
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                enabled: !_model.busy
                text: qsTr("Refresh")
                onClicked: _model.refresh(false);
            }
        }

        model: _model

        header: QuickdditPageHeader { title: multiredditsPage.title }

        delegate: ListItem {
            id: multiredditDelegate

            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: qsTr("About")
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AboutMultiredditPage.qml"), {multireddit: model.name} );
                        }
                    }
                }
            }

            onClicked: {
                multiredditsPage.multiredditName = model.name;
                multiredditsPage.accepted();
            }

            Column {
                anchors {
                    left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                    margins: constant.paddingLarge
                }
                spacing: constant.paddingSmall

                Row {
                    Text {
                        id: titleText
                        font.pixelSize: constant.fontSizeSmall
                        color: multiredditDelegate.highlighted ? Theme.highlightColor : constant.colorMid
                        text: "/m/"
                    }
                    Text {
                        anchors.baseline: titleText.baseline
                        font.pixelSize: constant.fontSizeMedium
                        color: multiredditDelegate.highlighted ? Theme.highlightColor : constant.colorLight
                        text: model.name
                    }
                }
            }
        }

        footer: LoadingFooter { visible: _model.busy; listViewItem: multiredditListView }

        ViewPlaceholder { enabled: multiredditListView.count == 0 && !_model.busy; text: qsTr("Nothing here :(") }
    }

}
