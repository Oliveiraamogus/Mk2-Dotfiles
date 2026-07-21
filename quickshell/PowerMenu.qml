import Quickshell
import Quickshell.Io
import QtQuick

import "./Theme.qml"

Item {
    id: root

    property color colBg: Theme.jsonData.colors.background
    property color colPri: Theme.jsonData.colors.primary
    property color colSec: Theme.jsonData.colors.secondary
    property string fontFamily: Theme.jsonData.fonts.body.family
    property int fontSize: Theme.jsonData.fonts.body.pixelSize

    signal closeRequested()

    implicitWidth: 160
    implicitHeight: column.implicitHeight + 20

    function run(cmd) {
        actionProc.command = ["sh", "-c", cmd]
        actionProc.running = true
        root.closeRequested()
    }

    Process {
        id: actionProc
    }

    Rectangle {
        anchors.fill: parent
        color: root.colBg
        radius: 8
        border.color: root.colSec
        border.width: 1
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 4

        Repeater {
            model: [
                { label: "Sleep", icon: "💤", cmd: "systemctl suspend" },
                { label: "Reboot", icon: "🔄", cmd: "systemctl reboot" },
                { label: "Shutdown", icon: "⏻", cmd: "systemctl poweroff" }
            ]

            Rectangle {
                required property var modelData
                width: column.width
                height: 32
                radius: 6
                color: btnArea.containsMouse ? root.colSec : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        text: modelData.icon
                        color: root.colPri
                        font { family: root.fontFamily; pixelSize: root.fontSize }
                    }

                    Text {
                        text: modelData.label
                        color: root.colPri
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    }
                }

                MouseArea {
                    id: btnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.run(modelData.cmd)
                }
            }
        }
    }
}
