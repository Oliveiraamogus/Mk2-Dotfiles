import Quickshell
import QtQuick

import "./Theme.qml"

Item {
    id: root

    property color colBg: Theme.jsonData.colors.background
    property color colPri: Theme.jsonData.colors.primary
    property color colSec: Theme.jsonData.colors.secondary
    property string fontFamily: Theme.jsonData.fonts.body.family
    property int fontSize: Theme.jsonData.fonts.body.pixelSize

    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth() // 0-11

    readonly property int todayYear: new Date().getFullYear()
    readonly property int todayMonth: new Date().getMonth()
    readonly property int todayDate: new Date().getDate()

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var dayNames: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // Monday-first offset of the 1st of the month (0 = Mon … 6 = Sun)
    readonly property int firstWeekday: {
        var dow = new Date(viewYear, viewMonth, 1).getDay();
        return (dow + 6) % 7;
    }
    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int cellCount: Math.ceil((firstWeekday + daysInMonth) / 7) * 7

    function prevMonth() {
        if (viewMonth === 0) {
            viewMonth = 11;
            viewYear -= 1;
        } else {
            viewMonth -= 1;
        }
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0;
            viewYear += 1;
        } else {
            viewMonth += 1;
        }
    }

    function goToToday() {
        viewYear = todayYear;
        viewMonth = todayMonth;
    }

    implicitWidth: 280
    implicitHeight: column.implicitHeight + 24

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
        anchors.margins: 12
        spacing: 10

        // Header: prev / month year / next
        Item {
            width: parent.width
            height: monthLabel.height

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "‹"
                color: root.colPri
                font { family: root.fontFamily; pixelSize: root.fontSize + 4; bold: true }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                }
            }

            Text {
                id: monthLabel
                anchors.centerIn: parent
                text: root.monthNames[root.viewMonth] + " " + root.viewYear
                color: root.colPri
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goToToday()
                }
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "›"
                color: root.colPri
                font { family: root.fontFamily; pixelSize: root.fontSize + 4; bold: true }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
                }
            }
        }

        // Weekday headers
        Grid {
            columns: 7
            width: parent.width
            Repeater {
                model: root.dayNames
                Text {
                    required property string modelData
                    width: parent.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: root.colSec
                    font { family: root.fontFamily; pixelSize: root.fontSize - 2; bold: true }
                }
            }
        }

        // Day grid
        Grid {
            id: dayGrid
            columns: 7
            width: parent.width
            rowSpacing: 4
            columnSpacing: 0

            Repeater {
                model: root.cellCount
                Item {
                    required property int index
                    width: dayGrid.width / 7
                    height: 28

                    readonly property int dayNum: index - root.firstWeekday + 1
                    readonly property bool inMonth: dayNum >= 1 && dayNum <= root.daysInMonth
                    readonly property bool isToday: inMonth
                        && root.viewYear === root.todayYear
                        && root.viewMonth === root.todayMonth
                        && dayNum === root.todayDate

                    Rectangle {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: 13
                        color: parent.isToday ? root.colPri : "transparent"
                        visible: parent.inMonth

                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.dayNum
                            color: parent.parent.isToday ? root.colBg : root.colPri
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: parent.parent.isToday }
                        }
                    }
                }
            }
        }
    }
}
