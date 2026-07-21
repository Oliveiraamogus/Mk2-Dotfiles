import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick

import "./Theme.qml"

Item {
    id: root

    property color colBg: Theme.jsonData.colors.background
    property color colPri: Theme.jsonData.colors.primary
    property color colSec: Theme.jsonData.colors.secondary
    property string fontFamily: Theme.jsonData.fonts.body.family
    property int fontSize: Theme.jsonData.fonts.body.pixelSize
    readonly property string currentId: Theme.jsonData.id

    signal closeRequested()

    readonly property string configDir: "/home/manel/.config"
    readonly property int columns: 3
    readonly property int cardWidth: 150
    readonly property int cardHeight: 118

    property var themeList: []

    // Re-scan the themes/ directory every time the menu is opened, so newly
    // added themes/scripts show up without restarting quickshell.
    function refresh() {
        root.themeList = []
        scanProc.running = true
    }

    Component.onCompleted: refresh()

    implicitWidth: grid.implicitWidth + 20
    implicitHeight: (root.themeList.length > 0 ? grid.implicitHeight : emptyLabel.implicitHeight) + 20

    function runTheme(themeId) {
        var script = root.configDir + "/scripts/" + themeId + ".sh"
        runProc.command = ["sh", "-c",
            "test -x '" + script + "' && '" + script + "'" +
            " || notify-send 'Theme' 'No script yet for " + themeId + "'"]
        runProc.running = true
        root.closeRequested()
    }

    Process {
        id: runProc
    }

    Process {
        id: scanProc
        command: ["bash", "-c", `
            for f in "$HOME/.config/themes"/*.json; do
                id=$(basename "$f" .json)
                [ "$id" = "current" ] && continue
                [ "$id" = "catppuccin_example" ] && continue
                wp=$(ls "$HOME/.config/Assets/Wallpapers/$id".* 2>/dev/null | head -1)
                script="$HOME/.config/scripts/$id.sh"
                has=0
                [ -x "$script" ] && has=1
                printf '%s|||%s|||%s\\n' "$id" "$wp" "$has"
            done
        `]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.split("|||")
                if (parts.length < 3) return
                var list = root.themeList.slice()
                list.push({
                    themeId: parts[0],
                    wallpaper: parts[1],
                    hasScript: parts[2] === "1"
                })
                root.themeList = list
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.colBg
        radius: 8
        border.color: root.colSec
        border.width: 1
    }

    Text {
        id: emptyLabel
        anchors.centerIn: parent
        visible: root.themeList.length === 0
        text: "No themes found"
        color: root.colSec
        font { family: root.fontFamily; pixelSize: root.fontSize }
    }

    Grid {
        id: grid
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        visible: root.themeList.length > 0
        columns: root.columns
        spacing: 8

        Repeater {
            model: root.themeList

            Rectangle {
                id: card
                required property var modelData
                width: root.cardWidth
                height: root.cardHeight
                radius: 8
                color: cardArea.containsMouse ? root.colSec : "transparent"
                border.width: modelData.themeId === root.currentId ? 2 : 0
                border.color: root.colPri
                opacity: modelData.hasScript ? 1.0 : 0.55

                Column {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    ClippingRectangle {
                        width: parent.width
                        height: root.cardHeight - 34
                        radius: 6
                        color: root.colSec
                        border.width: 1
                        border.color: root.colPri

                        Image {
                            anchors.fill: parent
                            source: card.modelData.wallpaper.length ? "file://" + card.modelData.wallpaper : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        Text {
                            visible: !card.modelData.hasScript
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 4
                            text: "no script"
                            color: "#ffffff"
                            font { family: root.fontFamily; pixelSize: root.fontSize - 4; bold: true }
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: modelData.themeId
                        color: root.colPri
                        font { family: root.fontFamily; pixelSize: root.fontSize - 2; bold: true }
                    }
                }

                MouseArea {
                    id: cardArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runTheme(card.modelData.themeId)
                }
            }
        }
    }
}
