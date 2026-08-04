pragma Singleton
import QtQml
import QtQuick
import Niri

Niri {
    id: niri
    Component.onCompleted: connect()

    onErrorOccurred: function (error) {
        console.error("Error:", error);
    }
}
