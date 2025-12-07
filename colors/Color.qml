pragma Singleton
import QtQuick

QtObject {
    enum Theme {
        Mocha,
        Latte
    }

    // This variable controls EVERYTHING
    property int colorTheme: Color.Theme.Mocha

    // Mocha palette
    readonly property var mocha: {
        "rosewater": "#f5e0dc",
        "flamingo":  "#f2cdcd",
        "pink":      "#f5c2e7",
        "mauve":     "#cba6f7",
        "blue":      "#89b4fa",
        "base":      "#1e1e2e"
    }

    // Latte palette
    readonly property var latte: {
        "rosewater": "#dc8a78",
        "flamingo":  "#dd7878",
        "pink":      "#ea76cb",
        "mauve":     "#8839ef",
        "blue":      "#1e66f5",
        "base":      "#efebe9"
    }

    function palette() {
        switch (colorTheme) {
        case Color.Theme.Mocha: return mocha
        case Color.Theme.Latte: return latte
        }
    }
}
