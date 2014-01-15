import QtQuick 2.0
import Sailfish.Silica 1.0

AbstractPage {
    id: mainPageMorePage
    title: "More"

    property bool enableFrontPage

    signal subredditsClicked
    signal multiredditsClicked

    Flickable {
        anchors.fill: parent
        contentHeight: pageHeader.height + optionsColumn.height

        PageHeader {
            id: pageHeader
            title: mainPageMorePage.title
        }

        Column {
            id: optionsColumn
            anchors { top: pageHeader.bottom; left: parent.left; right: parent.right }
            height: childrenRect.height

            BackgroundItem {
                height: Theme.itemSizeSmall
                enabled: enableFrontPage

                Label {
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    color: enableFrontPage ? constant.colorLight : constant.colorDisabled
                    text: "Front Page"
                }

                onClicked: {
                    pageStack.previousPage().refresh();
                    pageStack.pop();
                }
            }

            BackgroundItem {
                height: Theme.itemSizeSmall

                Label {
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Subreddits"
                }

                onClicked: subredditsClicked();
            }

            BackgroundItem {
                id: multiredditsItem
                height: Theme.itemSizeSmall
                enabled: quickdditManager.isSignedIn

                Label {
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    color: multiredditsItem.enabled ? constant.colorLight : constant.colorDisabled
                    text: "Multireddits"
                }

                onClicked: multiredditsClicked();
            }

            BackgroundItem {
                height: Theme.itemSizeSmall

                Label {
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Search"
                }

                onClicked: pageStack.replace(Qt.resolvedUrl("SearchDialog.qml"));
            }

            BackgroundItem {
                height: Theme.itemSizeSmall

                Label {
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Settings"
                }

                onClicked: pageStack.replace(Qt.resolvedUrl("AppSettingsPage.qml"))
            }

            BackgroundItem {
                height: Theme.itemSizeSmall

                Label {
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    text: "About"
                }

                onClicked: pageStack.replace(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }
}
