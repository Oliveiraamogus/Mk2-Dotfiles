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

    property var networkList: []
    property bool scanning: false
    property bool connected: false
    property string currentNetwork: ""

    readonly property string iface: "wlan0"

    signal closeRequested()

    implicitWidth: 300
    implicitHeight: column.implicitHeight + 20

    function refresh() {
        root.scanning = true
        root.networkList = []
        scanProc.running = true
    }

    function signalBars(n) {
        var s = ""
        for (var i = 0; i < 4; i++)
            s += i < n ? "▮" : "▯"
        return s
    }

    function disconnect() {
        actionProc.command = ["sh", "-c",
            "iwctl station " + root.iface + " disconnect"]
        actionProc.running = true
        root.closeRequested()
    }

    function connectTo(ssid, security, isKnown) {
        // Escape single quotes for shell: ' -> '\''
        var safe = ssid.replace(/'/g, "'\\''")
        var cmd
        if (security === "open" || isKnown) {
            cmd = "iwctl --dont-ask station " + root.iface + " connect '" + safe + "'"
        } else {
            cmd =
                "pass=$(zenity --password --title='WiFi: " + safe + "' 2>/dev/null) && " +
                "[ -n \"$pass\" ] && " +
                "iwctl --passphrase=\"$pass\" station " + root.iface + " connect '" + safe + "'"
        }
        actionProc.command = ["sh", "-c", cmd]
        actionProc.running = true
        root.closeRequested()
    }

    Component.onCompleted: refresh()

    Process {
        id: actionProc
    }

    Process {
        id: scanProc
        command: ["bash", "-c", `
            iface="${root.iface}"
            strip() { sed 's/\\x1b\\[[0-9;]*[mK]//g'; }

            iwctl station "$iface" scan >/dev/null 2>&1
            sleep 0.9

            show=$(iwctl station "$iface" show 2>/dev/null | strip)
            state=$(printf '%s\\n' "$show" | awk '/^[[:space:]]*State[[:space:]]/ {print $2; exit}')
            connected=$(printf '%s\\n' "$show" | awk '
                /^[[:space:]]*Connected network[[:space:]]/ {
                    sub(/^[[:space:]]*Connected network[[:space:]]+/, "")
                    gsub(/[[:space:]]+$/, "")
                    print
                    exit
                }
            ')
            if [ "$state" = "connected" ] && [ -n "$connected" ]; then
                printf 'STATUS|||1|||%s\\n' "$connected"
            else
                printf 'STATUS|||0|||\\n'
            fi

            known=$(iwctl known-networks list 2>/dev/null | strip | awk '
                /Name[[:space:]]+Security/ {next}
                /^-+/ {next}
                /Known Networks/ {next}
                NF == 0 {next}
                {
                    line = $0
                    sub(/^[[:space:]]+/, "", line)
                    if (match(line, /(psk|open|8021x)/)) {
                        name = substr(line, 1, RSTART - 1)
                        gsub(/[[:space:]]+$/, "", name)
                        if (name != "") print name
                    }
                }
            ')

            # Keep ANSI so dimmed stars (weak signal) can be dropped before counting.
            iwctl station "$iface" get-networks 2>/dev/null | awk -v known="$known" '
            BEGIN {
                n = split(known, ka, "\\n")
                for (i = 1; i <= n; i++) if (ka[i] != "") k[ka[i]] = 1
            }
            function strip_ansi(s) {
                gsub(/\\x1b\\[[0-9;]*[mK]/, "", s)
                return s
            }
            /Network name|Available networks|^-+/ { next }
            {
                raw = $0
                connected = 0
                if (match(raw, />/)) connected = 1

                # Drop dimmed star groups (\\x1b[1;90m***\\x1b[0m) = empty bars
                gsub(/\\x1b\\[1;90m[^*]*\\*+\\x1b\\[0m/, "", raw)
                line = strip_ansi(raw)
                gsub(/^[[:space:]]+/, "", line)
                sub(/^>[[:space:]]*/, "", line)
                if (line == "") next
                if (!match(line, /(psk|open|8021x)[[:space:]]+\\**/)) next
                rest = substr(line, RSTART)
                name = substr(line, 1, RSTART - 1)
                gsub(/[[:space:]]+$/, "", name)
                if (name == "") next
                match(rest, /(psk|open|8021x)/)
                security = substr(rest, RSTART, RLENGTH)
                bars = 0
                if (match(rest, /\\*+/)) bars = RLENGTH
                isknown = (name in k) ? 1 : 0
                printf "NET|||%d|||%s|||%s|||%d|||%d\\n", connected, name, security, bars, isknown
            }
            '
        `]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split("|||")
                if (parts.length < 2) return

                if (parts[0] === "STATUS") {
                    root.connected = parts[1] === "1"
                    root.currentNetwork = parts.length > 2 ? parts[2] : ""
                    return
                }

                if (parts[0] !== "NET" || parts.length < 6) return
                var list = root.networkList.slice()
                list.push({
                    active: parts[1] === "1",
                    ssid: parts[2],
                    security: parts[3],
                    bars: parseInt(parts[4]) || 0,
                    known: parts[5] === "1"
                })
                root.networkList = list
            }
        }
        onRunningChanged: {
            if (!running)
                root.scanning = false
        }
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

        // Header: status
        Text {
            width: column.width
            text: root.connected
                ? ("Connected: " + root.currentNetwork)
                : "Disconnected"
            color: root.colPri
            elide: Text.ElideRight
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }

        // Actions
        Row {
            spacing: 6
            width: column.width

            Rectangle {
                visible: root.connected
                width: disconnectLabel.implicitWidth + 16
                height: 28
                radius: 6
                color: disconnectArea.containsMouse ? root.colSec : "transparent"
                border.color: root.colSec
                border.width: 1

                Text {
                    id: disconnectLabel
                    anchors.centerIn: parent
                    text: "Disconnect"
                    color: root.colPri
                    font { family: root.fontFamily; pixelSize: root.fontSize - 1; bold: true }
                }

                MouseArea {
                    id: disconnectArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.disconnect()
                }
            }

            Rectangle {
                width: rescanLabel.implicitWidth + 16
                height: 28
                radius: 6
                color: rescanArea.containsMouse ? root.colSec : "transparent"
                border.color: root.colSec
                border.width: 1

                Text {
                    id: rescanLabel
                    anchors.centerIn: parent
                    text: root.scanning ? "Scanning…" : "Rescan"
                    color: root.colPri
                    font { family: root.fontFamily; pixelSize: root.fontSize - 1; bold: true }
                }

                MouseArea {
                    id: rescanArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.scanning
                    onClicked: root.refresh()
                }
            }
        }

        Rectangle {
            width: column.width
            height: 1
            color: root.colSec
            opacity: 0.5
        }

        Text {
            visible: root.scanning && root.networkList.length === 0
            width: column.width
            text: "Scanning…"
            color: root.colSec
            font { family: root.fontFamily; pixelSize: root.fontSize }
        }

        Text {
            visible: !root.scanning && root.networkList.length === 0
            width: column.width
            text: "No networks found"
            color: root.colSec
            font { family: root.fontFamily; pixelSize: root.fontSize }
        }

        Repeater {
            model: root.networkList

            Rectangle {
                required property var modelData
                width: column.width
                height: 32
                radius: 6
                color: rowArea.containsMouse ? root.colSec : "transparent"
                border.width: modelData.active ? 1 : 0
                border.color: root.colPri

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        width: parent.width - signalText.width - lockText.width - 16
                        elide: Text.ElideRight
                        text: (modelData.active ? "● " : "") + modelData.ssid
                        color: root.colPri
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                    }

                    Text {
                        id: lockText
                        text: modelData.security === "open" ? "○" : "🔒"
                        color: root.colSec
                        font { family: root.fontFamily; pixelSize: root.fontSize - 2 }
                    }

                    Text {
                        id: signalText
                        text: root.signalBars(modelData.bars)
                        color: root.colPri
                        font { family: root.fontFamily; pixelSize: root.fontSize - 2 }
                    }
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.active)
                            return
                        root.connectTo(modelData.ssid, modelData.security, modelData.known)
                    }
                }
            }
        }
    }
}
