import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "./Theme.qml"

PanelWindow {

    id: root

    // Theme
    property color colBg: Theme.jsonData.colors.background
    property color colPri: Theme.jsonData.colors.primary
    property color colSec: Theme.jsonData.colors.secondary
    property string fontFamily: Theme.jsonData.fonts.body.family
    property int fontSize: Theme.jsonData.fonts.body.pixelSize

    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property int batUsage: 0
    property bool isCharging: false
    property bool isCharged: false
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // Processes and timers here...

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: root.colBg


    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Workspaces
        Repeater {
            Layout.alignment: Qt.AlignLeft
            model: 9
            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? root.colPri : (ws ? root.colPri : root.colSec)
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Clock
        Text {
            id: clock
            //This gives a warning, TODO: fix, maybe using Layout.alignment
            anchors.centerIn: parent
            color: root.colPri
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            }
            Process {
                id: callendar
                command: ["sh", "-c", "quickshell --path ~/.config/quickshell/Callendar.qml"]
                Component.onCompleted: running = false
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button == Qt.RightButton){
                        if (callendar.running == true)
                            callendar.running = false
                        else
                            callendar.running = true
                    }
                }     
            }
        }

        Item { Layout.fillWidth: true }

        
        Text{
            Layout.alignment: Qt.AlignRight
            text: "Theme: " + Theme.jsonData.name
            color: root.colPri
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }

        Rectangle { Layout.alignment: Qt.AlignRight; width: 1; height: 16; color: root.colSec }

        // CPU
        Text {
            Layout.alignment: Qt.AlignRight
            Process {
                id: cpuProc
                command: ["sh", "-c", "head -1 /proc/stat"]
                stdout: SplitParser {
                onRead: data => {
                    if (!data) return
                    var p = data.trim().split(/\s+/)
                    var idle = parseInt(p[4]) + parseInt(p[5])
                    var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                    if (lastCpuTotal > 0) {
                        cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                    }
                    lastCpuTotal = total
                    lastCpuIdle = idle
                }
            }
                Component.onCompleted: running = true
            }

            Timer {
                interval: 500        // Every half second
                running: true         // Start immediately
                repeat: true          // Keep going forever
                onTriggered: cpuProc.running = true
            }

            text: "CPU: " + cpuUsage + "%"
            color: root.colPri
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }

        Rectangle { Layout.alignment: Qt.AlignRight; width: 1; height: 16; color: root.colSec }

        // Memory
        Text {
            Layout.alignment: Qt.AlignRight
            // Memory process
            Process {
                id: memProc
                command: ["sh", "-c", "free | grep Mem"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var total = parseInt(parts[1]) || 1
                        var used = parseInt(parts[2]) || 0
                        memUsage = Math.round(100 * used / total)
                    }
                }
                Component.onCompleted: running = true
            }

            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: {
                    memProc.running = true
                }
            }


            text: "Mem: " + memUsage + "%"
            color: root.colPri
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }

        Rectangle { Layout.alignment: Qt.AlignRight; width: 1; height: 16; color: root.colSec }

        //Battery
        Text {
            Layout.alignment: Qt.AlignRight
            Process {
                id: batState
                command: ["sh", "-c", "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E state"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        if (parts[1] == "fully-charged") {
                            isCharged = true
                            return
                        } 
                        if (parts[1] == "charging") {
                            isCharging = true
                            return
                        }
                        else {
                            isCharged = false
                            isCharging = false
                        }
                    }
                }
                Component.onCompleted: running = true
            }
            Process {
                id: batAmount
                command: ["sh", "-c", "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E percentage"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        batUsage = parseInt(parts[1])
                    }
                }
                Component.onCompleted: running = true
            }

            Timer {
                interval: 500
                running: true
                repeat: true
                onTriggered: {
                    batState.running = true
                    batAmount.running = true
                }
            }

            text: isCharged ? "Charged" : (isCharging ? "Bat: " + batUsage + "% ⚡" : "Bat: " + batUsage + "%")
            color: root.colPri
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }

        }

    }
}
