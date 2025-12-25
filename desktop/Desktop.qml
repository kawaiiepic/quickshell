import Quickshell // for PanelWindow
import Quickshell.Io
import Quickshell.Wayland
import QtQuick // for Text
import Qt5Compat.GraphicalEffects
import "./components/overlay"

Scope {
  id: root
  
  property var wallpaperSrc: "/home/mia/Downloads/7ts7l7beon6e1.jpg"

  Border {}
  Wallpaper {}
  // ActivateLinux {}
  VolumeOSD {}
  Icons {}
}