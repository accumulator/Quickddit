import QtQuick 2.9
import QtQuick.Controls 2.2
import quickddit.Core 1.0
import QtQuick.Controls.Suru 2.2

Item {
    height: formatRow.height+richTextArea.height
    property alias text: richTextArea.text

    Row {
        id: formatRow
        height: Suru.units.gu(4.5)

        anchors { top: parent.top; left: parent.left }
        ActionButton {
            text: "B"
            font.bold: true
            font.family: "Serif"
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "****");
                richTextArea.cursorPosition -= 2
            }
        }

        ActionButton {
            text: "I"
            font.bold: true
            font.italic: true
            font.family: "Serif"
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "**");
                richTextArea.cursorPosition -= 1
            }
        }

        ActionButton {
            text: "S"
            font.bold: true
            font.strikeout: true
            font.family: "Serif"
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "~~~~");
                richTextArea.cursorPosition -= 2
            }
        }
        ActionButton {
            text: "</>"
            font.bold: true
            font.family: "Serif"
            font.pixelSize: 11
            onClicked: {
                richTextArea.insert(richTextArea.cursorPosition, "``");
                richTextArea.cursorPosition -= 1
            }
        }
        ActionButton {
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
    }

    TextArea {
        id:richTextArea
        anchors { left: parent.left; right: parent.right; top: formatRow.bottom }
        selectByKeyboard: true
        selectByMouse: true
        persistentSelection: true
        textFormat: "PlainText"
        onTextChanged: focus = true
    }
}
