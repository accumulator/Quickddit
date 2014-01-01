import QtQuick 2.0
import Sailfish.Silica 1.0

// TODO: redesign cover page
CoverBackground {
    id: coverBackground

    property Item mainPage: pageStack.find(function(page) { return page.objectName == "mainPage"; })

    CoverPlaceholder {
        text: pageStack.currentPage.title || mainPage.title
        icon.source: "quickddit.png"
    }
}
