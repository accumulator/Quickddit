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
        ToolButton {
            text: quickdditManager.signedIn ? "Sign out" : "Sign in"
            onClicked: {
                if (quickdditManager.signedIn)
                    quickdditManager.signOut();
                else
                    pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
            }
        }
        Item {
            width: 80; height: 64
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
        }
    }

    PageHeader {
        id: pageHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        text: "App Settings"
    }
}
