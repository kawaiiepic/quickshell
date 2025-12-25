//@ pragma UseQApplication
//@ pragma IconTheme Papirus

import Quickshell // for PanelWindow
import QtQuick // for Text
import "./desktop"
import "./bar"
import "./notifications"
import "./controlcenter"

Scope {
  // Shell
  Bar {}
  Desktop {}
  Notifications {}
  ControlCenter {}

}
