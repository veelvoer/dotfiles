// qmllint disale
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 6

    Repeater {
        model: 9

        Rectangle {
            id: wsButton
            required property int index

            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            implicitWidth: label.implicitWidth + 14
            implicitHeight: 22
            radius: 6

            color: isActive ? main.wsa : (ws ? main.wso : main.wsi)

            Behavior on color {
                
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: wsButton.index + 1
                color: wsButton.isActive ? main.wst : (wsButton.ws ? main.wsti : main.wsti)

                font {
                    family: "Inter"
                    pixelSize: 13
                    weight: 650
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (parent.index + 1) + "})")
            }
        }
    }
}

