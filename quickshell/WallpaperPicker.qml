
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel

Scope {
    id: root
    property bool open: false

    readonly property string home: Quickshell.env("HOME")
    readonly property string wallsDir:  home + "/Pictures/Wallpapers"
    readonly property string thumbsDir: home + "/.cache/wallpaper-thumbs"
    readonly property string setScript: home + "/.config/hypr/scripts/set-wallpaper.sh"
    readonly property string thumbScript: home + "/.config/quickshell/scripts/wall-thumbs.sh"

// ───────────────────── wait fix 
    readonly property color cardBg:     Colors.md3.surface
    readonly property color cardBorder: Colors.md3.primary
    readonly property color labelColor: "#e6e6e6"

    readonly property var focusedScreen: {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
        return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0]
    }


    function originalOf(thumbName) {
        return root.wallsDir + "/" + String(thumbName).replace(/\.jpg$/, "")
    }

    function apply(thumbName) {
        Quickshell.execDetached([root.setScript, root.originalOf(thumbName)])
        root.open = false
    }


    Process {
        id: thumbsProc
        command: ["bash", root.thumbScript]
        onExited: {
            if (wallModel.count === 0) {
                wallModel.folder = ""
                wallModel.folder = "file://" + root.thumbsDir
            }
        }
    }
    function refreshThumbs() { thumbsProc.running = false; thumbsProc.running = true }
    Component.onCompleted: root.refreshThumbs()


    GlobalShortcut {
        name: "wallpaper"
        description: "Wallpaper picker"
        onPressed: root.open = !root.open
    }
    HyprlandFocusGrab { windows: [win]; active: root.open; onCleared: root.open = false }

    FolderListModel {
        id: wallModel
        folder: "file://" + root.thumbsDir
        nameFilters: ["*.jpg"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    PanelWindow {
        id: win
        screen: root.focusedScreen
        visible: root.open
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: "quickshell:wallpaper"

        Item {
            id: stage
            anchors.fill: parent
            focus: true

            Connections {
                target: root
                function onOpenChanged() {
                    if (!root.open) return
                    stage.forceActiveFocus()
                    root.refreshThumbs()
                }
            }

            Keys.onEscapePressed: root.open = false
            Keys.onLeftPressed:   carousel.decrementCurrentIndex()
            Keys.onRightPressed:  carousel.incrementCurrentIndex()
            Keys.onReturnPressed: carousel.applyCurrent()
            Keys.onEnterPressed:  carousel.applyCurrent()

            WheelHandler {
                onWheel: (e) => {
                    if (e.angleDelta.y > 0 || e.angleDelta.x > 0) carousel.decrementCurrentIndex()
                    else carousel.incrementCurrentIndex()
                }
            }

            MouseArea { anchors.fill: parent; z: -1; onClicked: root.open = false }

            ListView {
                id: carousel
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 12
                }
                height: 560
                orientation: ListView.Horizontal
                model: wallModel

                property real iw: 720          // chiều rộng card chính
                property real ih: 406          // chiều cao card chính (~16:9)
                property real skew: -0.35
                property real bw: 3            // viền
                property real slotW: 360       // bước cuộn cố định
                property real sideBase: 0.56   // scale của card kế bên
                readonly property real imgW: iw + ih * Math.abs(skew) + 12

                spacing: 0
                clip: false
                cacheBuffer: 2500
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (width - slotW) / 2
                preferredHighlightEnd:   (width + slotW) / 2
                highlightMoveDuration: 420
                highlightMoveVelocity: 3000
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                maximumFlickVelocity: 6000

                function applyCurrent() {
                    if (currentIndex < 0 || wallModel.count <= currentIndex) return
                    root.apply(wallModel.get(currentIndex, "fileName"))
                }

                delegate: Item {
                    id: slot
                    width: carousel.slotW
                    height: carousel.height

                    readonly property real d: (x + width / 2 - (carousel.contentX + carousel.width / 2)) / carousel.slotW
                    readonly property real ad: Math.abs(d)
                    readonly property real sc: ad <= 1
                        ? carousel.sideBase + (1 - carousel.sideBase) * Math.pow(1 - ad, 1.35)
                        : carousel.sideBase * Math.pow(0.86, ad - 1)

                    z: Math.round(100 - ad * 10)
                    opacity: Math.max(0, Math.min(1, 1.15 - 0.34 * ad))

                    Item {
                        id: card
                        anchors.centerIn: parent
                        width: carousel.iw
                        height: carousel.ih
                        scale: slot.sc
                        transformOrigin: Item.Center
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, carousel.skew, 0, -carousel.skew * carousel.ih / 2,
                                                 0, 1, 0, 0,
                                                 0, 0, 1, 0,
                                                 0, 0, 0, 1)
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: root.cardBg
                            border.width: 1.5
                            border.color: root.cardBorder
                        }

                        Item {
                            anchors.fill: parent
                            anchors.margins: carousel.bw
                            clip: true
                            Image {
                                anchors.centerIn: parent
                                width: carousel.imgW
                                height: carousel.ih
                                fillMode: Image.PreserveAspectCrop
                                source: model.fileUrl
                                asynchronous: true
                                cache: true
                                mipmap: true
                                sourceSize: Qt.size(carousel.imgW, carousel.ih)
                                transform: Matrix4x4 {
                                    matrix: Qt.matrix4x4(1, -carousel.skew, 0, carousel.skew * carousel.ih / 2,
                                                         0, 1, 0, 0,
                                                         0, 0, 1, 0,
                                                         0, 0, 0, 1)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: slot.ad < 0.5 ? carousel.applyCurrent() : (carousel.currentIndex = index)
                        }
                    }
                }
            }

            // Text {
            //     anchors.centerIn: parent
            //     visible: wallModel.count === 0
            //     text: "Không có wallpaper trong ~/Pictures/wallpapers"
            //     color: root.labelColor
            //     font.pixelSize: 20
            //     style: Text.Outline
            //     styleColor: "#000000"
            // }
        }
    }
}

