import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Page {
    id: appSettingsPage

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Flickable {
        id: settingFlickable
        anchors { top: pageHeader.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentHeight: settingColumn.height + 2 * constant.paddingMedium

        Column {
            id: settingColumn
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            height: childrenRect.height
            spacing: constant.paddingMedium

            SectionHeader { title: "Display" }

            SettingButtonRow {
                text: "Theme"
                checkedButtonIndex: appSettings.whiteTheme ? 1 : 0
                buttonsText: ["Dark", "White"]
                onButtonClicked: appSettings.whiteTheme = index == 1
            }

            SettingButtonRow {
                text: "Font Size"
                checkedButtonIndex: {
                    switch (appSettings.fontSize) {
                    case AppSettings.SmallFontSize: return 0;
                    case AppSettings.MediumFontSize: return 1;
                    case AppSettings.LargeFontSize: return 2;
                    }
                }
                buttonsText: ["Small", "Medium", "Large"]
                onButtonClicked: {
                    switch (index) {
                    case 0: appSettings.fontSize = AppSettings.SmallFontSize; break;
                    case 1: appSettings.fontSize = AppSettings.MediumFontSize; break;
                    case 2: appSettings.fontSize = AppSettings.LargeFontSize; break;
                    }
                }
            }

            SectionHeader { title: "Account" }

            Text {
                anchors { left: parent.left; right: parent.right }
                font.pixelSize: constant.fontSizeMedium
                color: constant.colorLight
                visible: quickdditManager.signedIn
                horizontalAlignment: Text.AlignHCenter
                text: "Signed in to Reddit"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: quickdditManager.signedIn ? "Sign out" : "Sign in to Reddit"
                onClicked: {
                    if (quickdditManager.signedIn) {
                        quickdditManager.signOut();
                        infoBanner.alert("You have signed out from Reddit");
                     } else {
                        pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
                    }
                }
            }
        }
    }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "App Settings"
    }
}
