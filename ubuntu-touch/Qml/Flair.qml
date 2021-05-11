import QtQuick 2.12
import QtQuick.Controls 2.12

Label {
    padding: 3
    font.weight: Font.Normal
    background: Rectangle {
        color: parent.text === "NSFW" ? persistantSettings.redColor :
               parent.text.includes("Gilded") ? "gold" :
               parent.text === "Promoted" ? persistantSettings.greenColor :
               parent.text === "Archived" ? "silver" :
               parent.text === "Locked" ? "dodgerblue" :
               parent.text === "Sticky" ? persistantSettings.greenColor :
               persistantSettings.primaryColor
        radius: 4
    }
}
