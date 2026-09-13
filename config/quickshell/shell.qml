// qmllint disable
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    property string activeTheme: "teal"

    readonly property var main: themes[activeTheme]

    readonly property var themes: {
        "pink": {
            "bg":     "#18265A",
            "border": "#e835477f",
            "text":   "#FFF4E0",
            "wsa":    "#FF7188",
            "wso":    "#C75D83",
            "wsi":    "#29396D",
            "wst":    "#FFF7F8",
            "wsti":   "#C7CBE0",
            "icon":   "#FF8FA3"
        },
        "yellow": {
            "bg":     "#18265A",
            "border": "#FFD36A7F",
            "text":   "#FFF4E0",
            "wsa":    "#FFD36A",
            "wso":    "#C9A44F",
            "wsi":    "#29396D",
            "wst":    "#FFF9E8",
            "wsti":   "#D8D0B8",
            "icon":   "#FFE08A"
        },
        "green": {
            "bg":     "#18265A",
            "border": "#5FC98A7F",
            "text":   "#F1FFF6",
            "wsa":    "#62C98C",
            "wso":    "#3E8B6A",
            "wsi":    "#29396D",
            "wst":    "#F4FFF8",
            "wsti":   "#B8D8C7",
            "icon":   "#7BE0A5"
        },
        "blue": {
            "bg":     "#18265A",
            "border": "#4BB9E87F",
            "text":   "#F0FAFF",
            "wsa":    "#4BB9E8",
            "wso":    "#357FA8",
            "wsi":    "#29396D",
            "wst":    "#F2FBFF",
            "wsti":   "#B7D4E3",
            "icon":   "#73C9F0"
        },
        "teal": {
            "bg": "#12424C",
            "border": "#219BA47F",
            "text": "#E8F8FA",
            "wsa": "#2BB1BB",
            "wso": "#186A73",
            "wsi": "#12424C",
            "wst": "#F2FCFD",
            "wsti": "#92D5DD",
            "icon": "#3FD0DC"
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            id: window
            color: "transparent"
            height: 30
            

            Rectangle {
                anchors.fill: parent
                color: main.bg
                radius: 15
                opacity: 0.88
                border.color: main.border
                border.width: 1
            }
            margins {
                top: 4
                bottom: -2
                left: 10
                right: 10
            }
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                
                RowLayout {
                    spacing: 10
                    Workspaces { }
                    
                    Item { Layout.fillWidth: true}

                    Clock { }
                    


                    Volume { }
                    Network { }
                    Battery { }
                    
                }
            }
        }
    }
}
