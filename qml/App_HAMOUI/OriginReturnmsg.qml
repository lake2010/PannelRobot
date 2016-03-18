import QtQuick 1.1
import "../ICCustomElement"
import "ShareData.js" as ShareData

MouseArea{
    id:container
    width: 800
    height: 600
    x:0
    y:0
    property alias hinttext: hinttext.text
    property alias msgtext: msgtext.text
    Rectangle {
        id: continer
        width: 360
        height: 140
        border.width: 1
        border.color: "black"
        anchors.centerIn: parent
        color: "#A0A0F0"


        Text {
            id: hinttext
            text: qsTr("top text")
        }
        Text {
            id: msgtext
            anchors.bottom: parent.bottom
            text: qsTr("bottom text")
        }

    }
}