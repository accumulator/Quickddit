import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

Label {
    padding: 3
    color: Suru.backgroundColor
    font.weight: Font.Normal
    background: Rectangle {
        color: parent.text === "NSFW" ? Suru.color(Suru.Red) :
               parent.text.includes("Gilded") ? Suru.color(Suru.Yellow) :
               parent.text === "Promoted" ? Suru.color(Suru.Graphite) :
               parent.text === "Archived" ? Suru.color(Suru.Purple) :
               parent.text === "Locked" ? Suru.color(Suru.Blue) :
               parent.text === "Sticky" ? Suru.color(Suru.Green) :
               Suru.color(Suru.Orange)
        radius: 4
    }
}
