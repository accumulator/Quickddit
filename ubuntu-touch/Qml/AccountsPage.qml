import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0

Page {
    title: "Accounts"

    ListView {
        id:accountsView
        anchors.fill: parent

        model:appSettings.accountNames

        delegate: ItemDelegate {
            width: parent.width
            text: modelData
            highlighted: modelData === appSettings.redditUsername

            ToolButton {
                anchors.right: parent.right
                anchors.rightMargin: 12
                height: parent.height
                hoverEnabled: false

                Image {
                    height: 24
                    width: 24
                    anchors.centerIn: parent
                    source: "../Icons/delete.svg"
                }
                onClicked: {
                    if(modelData === appSettings.redditUsername )
                        quickdditManager.signOut();
                    appSettings.removeAccount(modelData);
                }
            }
            onClicked: {
                quickdditManager.selectAccount(modelData);
                pageStack.pop(globalUtils.getMainPage(),StackView.ReplaceTransition)
            }
        }

        footer: ItemDelegate {
            width: parent.width
            text: "Add new account"

            onClicked: {
                pageStack.push(Qt.resolvedUrl("LoginPage.qml"));
            }
        }
    }

}
