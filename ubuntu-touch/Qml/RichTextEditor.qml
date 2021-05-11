import QtQuick 2.12
import QtQuick.Controls 2.12
import quickddit.Core 1.0
//

Item {
    height: formatRow.height+richTextArea.height+editRow.height
    property alias text: richTextArea.text

    Row {
        id: formatRow

        anchors { top: parent.top; left: parent.left }
        ToolButton {
            icon.name: "format-text-bold-symbolic"
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "****");
                richTextArea.cursorPosition -= 2
            }
        }

        ToolButton {
            icon.name: "format-text-italic-symbolic"
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "**");
                richTextArea.cursorPosition -= 1
            }
        }

        ToolButton {
            icon.name: "format-text-strikethrough-symbolic"
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "~~~~");
                richTextArea.cursorPosition -= 2
            }
        }
        ToolButton {
            text: "</>"
            font.bold: true
            font.family: "Serif"
            font.pixelSize: 11
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "``");
                richTextArea.cursorPosition -= 1
            }
        }
        ToolButton {
            Text {
                anchors.centerIn: parent
                text: "A<sup>a</sup>"
                font.family: "Serif"
                textFormat: Text.RichText
            }

            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "^()");
                richTextArea.cursorPosition -= 1
            }
        }
        ToolButton {
            icon.name: "insert-link-symbolic"

            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition,"[](link)");
                richTextArea.cursorPosition -= 5;
                richTextArea.select(richTextArea.cursorPosition,richTextArea.cursorPosition + 4)
            }
        }
    }

    Row {
        id: editRow

        anchors { top: formatRow.bottom; left: parent.left }
        ToolButton {
            icon.name: "edit-undo-symbolic"
            enabled: richTextArea.canUndo
            onClicked: richTextArea.undo()
        }
        ToolButton {
            icon.name: "edit-redo-symbolic"
            enabled: richTextArea.canRedo
            onClicked: richTextArea.redo()
        }
        ToolButton {
            icon.name: "edit-copy-symbolic"
            enabled: richTextArea.selectedText
            onClicked: richTextArea.copy()
        }
        ToolButton {
            icon.name: "edit-cut-symbolic"
            enabled: richTextArea.selectedText
            onClicked: richTextArea.cut()
        }
        ToolButton {
            icon.name: "edit-paste-symbolic"
            enabled: richTextArea.canPaste
            onClicked: richTextArea.paste()
        }
    }

    TextArea {
        id:richTextArea
        anchors { left: parent.left; right: parent.right; top: editRow.bottom }
        selectByKeyboard: true
        selectByMouse: true
        persistentSelection: true
        textFormat: "PlainText"
        onTextChanged: focus = true
    }
}
