// qmllint disable
import Quickshell
import QtQuick
import QtQuick.Layouts

Text {
    text: Qt.formatDateTime(clock.date, "hh:mm")
    color: main.text
    anchors.centerIn: parent

    font {
        family: "Inter"
        letterSpacing: 0
        pixelSize: 14
        weight: 600
    }
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
