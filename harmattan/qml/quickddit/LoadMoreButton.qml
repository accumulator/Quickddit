import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: loadMoreButton

    signal clicked

    width: ListView.view.width
    height: visible ? button.height + 2 * constant.paddingMedium : 0

    Button {
        id: button
        anchors.centerIn: parent
        enabled: parent.enabled
        text: "Load More"
        onClicked: loadMoreButton.clicked();
    }
}
