/*
    Quickddit - Reddit client for mobile phones
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

Item {
    id: rootItem

    property string body
    property ListItem listItem

    signal clicked

    height: commentLoader.height

    Loader {
        id: commentLoader
        sourceComponent: normalCommentComponent
    }

    Component {
        id: normalCommentComponent
        Text {
            id: commentBodyTextInner
            width: rootItem.width
            font.pixelSize: constant.fontSizeDefault
            color: listItem.enabled ? (listItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                    : constant.colorDisabled
            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: "<style>a { color: " + (listItem.enabled ? Theme.highlightColor : constant.colorDisabled) + "; }</style>" + body
            onLinkActivated: globalUtils.openLink(link);

            Component.onCompleted: {
                if (commentBodyTextInner.paintedWidth > listItem.width && commentLoader.sourceComponent != wideCommentComponent) {
                    commentLoader.sourceComponent = wideCommentComponent
                }
            }
        }
    }

    Component {
        id: wideCommentComponent
        Flickable {
            width: rootItem.width
            height: childrenRect.height
            contentWidth: commentBodyTextInner.paintedWidth
            contentHeight: commentBodyTextInner.height
            flickableDirection: Flickable.HorizontalFlick
            clip: true

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
                onClicked: rootItem.clicked()
                onPressed: listItem.onPressed(mouse)
                onReleased: listItem.onReleased(mouse)
            }

            Text {
                id: commentBodyTextInner
                width: rootItem.width
                font.pixelSize: constant.fontSizeDefault
                color: listItem.enabled ? (listItem.highlighted ? Theme.highlightColor : constant.colorLight)
                                        : constant.colorDisabled
                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: "<style>a { color: " + (listItem.enabled ? Theme.highlightColor : constant.colorDisabled) + "; }</style>" + body
                onLinkActivated: globalUtils.openLink(link);
            }
        }
    }

}

