import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

import "./Theme.qml"

Scope {
    id: root

    // Theme
    property color colBg: Theme.jsonData.colors.background
    property color colPri: Theme.jsonData.colors.primary
    property color colSec: Theme.jsonData.colors.secondary
    property string fontFamily: Theme.jsonData.fonts.body.family
    property int fontSize: Theme.jsonData.fonts.body.pixelSize

    // System data (shared across all monitors)
    property bool volMuted: false
    property int volAmount: 0
    property int cpuUsage: 0
    property int memUsage: 0
    property int batUsage: 0
    property bool isCharging: false
    property bool isCharged: false
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property bool networkConnected: false
    property string network: ""
    property string clockText: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")

    // Clock
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.clockText = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    }

    // Sound
    Process {
        id: mutProc
        command: ["sh", "-c", "pamixer --get-mute"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                root.volMuted = (p == "true")
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: volProc
        command: ["sh", "-c", "pamixer --get-volume"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                root.volAmount = parseInt(p)
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            mutProc.running = true
            volProc.running = true
        }
    }

    // CPU
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)))
                }
                root.lastCpuTotal = total
                root.lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }

    // Memory
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                root.memUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }

    // Network
    Process {
        id: connectedProc
        command: ["sh", "-c", "iwctl station wlan0 show | grep State"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                root.networkConnected = (p[1] == "connected")
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: networkProc
        command: ["sh", "-c", "iwctl station wlan0 show | grep 'Connected network'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                root.network = parts[2]
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            networkProc.running = true
            connectedProc.running = true
        }
    }

    // Battery
    Process {
        id: batState
        command: ["sh", "-c", "upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E state"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                if (parts[1] == "fully-charged") {
                    root.isCharged = true
                    return
                }
                if (parts[1] == "charging") {
                    root.isCharging = true
                    return
                }
                root.isCharged = false
                root.isCharging = false
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
                root.batUsage = parseInt(parts[1])
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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            readonly property var hyprMonitor: Hyprland.monitorFor(modelData)

            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 30
            color: root.colBg

            Item {
                anchors.fill: parent

                // Scroll anywhere on the bar to change workspace
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        if (event.angleDelta.y > 0)
                            Hyprland.dispatch("workspace -1")
                        else if (event.angleDelta.y < 0)
                            Hyprland.dispatch("workspace +1")
                    }
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: 8

                    // Left: workspaces
                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Repeater {
                            model: 9
                            Text {
                                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                                property bool isActive: bar.hyprMonitor?.activeWorkspace?.id === (index + 1)
                                text: index + 1
                                color: isActive ? root.colPri : (ws ? root.colPri : root.colSec)
                                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                                }
                            }
                        }
                    }

                    // Center: clock (true bar center, independent of side widths)
                    Text {
                        id: clockLabel
                        anchors.centerIn: parent
                        color: root.colPri
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        text: root.clockText
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onClicked: (mouse) => {
                                if (mouse.button == Qt.LeftButton) {
                                    powerPopup.visible = false
                                    if (!calendarPopup.visible)
                                        calendarWidget.goToToday()
                                    calendarPopup.visible = !calendarPopup.visible
                                }
                            }
                        }
                    }

                    // Right: status modules
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            text: "Theme: " + Theme.jsonData.name
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        }

                        Rectangle { width: 1; height: 16; anchors.verticalCenter: parent.verticalCenter; color: root.colSec }

                        Text {
                            text: root.volMuted ? "🔇" : (root.volAmount < 50) ? "🔈 " + root.volAmount : (root.volAmount < 75) ? "🔉 " + root.volAmount : "🔊 " + root.volAmount
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        }

                        Rectangle { width: 1; height: 16; anchors.verticalCenter: parent.verticalCenter; color: root.colSec }

                        Text {
                            text: "CPU: " + root.cpuUsage + "%"
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        }

                        Rectangle { width: 1; height: 16; anchors.verticalCenter: parent.verticalCenter; color: root.colSec }

                        Text {
                            text: "Mem: " + root.memUsage + "%"
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        }

                        Rectangle { width: 1; height: 16; anchors.verticalCenter: parent.verticalCenter; color: root.colSec }

                        Text {
                            text: root.networkConnected ? "🛜 " + root.network : "Disconected"
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        }

                        Rectangle { width: 1; height: 16; anchors.verticalCenter: parent.verticalCenter; color: root.colSec }

                        Text {
                            text: root.isCharged ? "Charged" : (root.isCharging ? "Bat: " + root.batUsage + "% ⚡" : "Bat: " + root.batUsage + "%")
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        }

                        Rectangle { width: 1; height: 16; anchors.verticalCenter: parent.verticalCenter; color: root.colSec }

                        // Power
                        Text {
                            id: powerButton
                            text: "⏻"
                            color: root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    calendarPopup.visible = false
                                    powerPopup.visible = !powerPopup.visible
                                }
                            }
                        }
                    }
                }
            }

            PopupWindow {
                id: calendarPopup
                anchor.window: bar
                anchor.rect.x: bar.width / 2 - width / 2
                anchor.rect.y: bar.height + 4
                implicitWidth: calendarWidget.implicitWidth
                implicitHeight: calendarWidget.implicitHeight
                color: "transparent"
                grabFocus: true
                visible: false

                Callendar {
                    id: calendarWidget
                }
            }

            PopupWindow {
                id: powerPopup
                anchor.window: bar
                anchor.rect.x: bar.width - width - 8
                anchor.rect.y: bar.height + 4
                implicitWidth: powerMenu.implicitWidth
                implicitHeight: powerMenu.implicitHeight
                color: "transparent"
                grabFocus: true
                visible: false

                PowerMenu {
                    id: powerMenu
                    onCloseRequested: powerPopup.visible = false
                }
            }
        }
    }
}
