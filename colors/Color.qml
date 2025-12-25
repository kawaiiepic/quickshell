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
        "flamingo": "#f2cdcd",
        "pink": "#f5c2e7",
        "mauve": "#cba6f7",
        "red": "#f38ba8",
        "maroon": "#eba0ac",
        "peach": "#fab387",
        "yellow": "#f9e2af",
        "green": "#a6e3a1",
        "teal": "#94e2d5",
        "sky": "#89dceb",
        "sapphire": "#74c7ec",
        "blue": "#89b4fa",
        "lavender": "#b4befe",
        "text": "#cdd6f4",
        "subtext1": "#bac2de",
        "subtext0": "#a6adc8",
        "overlay2": "#9399b2",
        "overlay1": "#7f849c",
        "overlay0": "#6c7086",
        "surface2": "#585b70",
        "surface1": "#45475a",
        "surface0": "#313244",
        "base": "#1e1e2e",
        "mantle": "#181825",
        "crust": "#11111b"
    }

    // Latte palette
    readonly property var latte: {
        "rosewater": "#dc8a78",
        "flamingo": "#dd7878",
        "pink": "#ea76cb",
        "mauve": "#8839ef",
        "blue": "#1e66f5",
        "base": "#efebe9"
    }

    function palette() {
        switch (colorTheme) {
        case Color.Theme.Mocha:
            return mocha;
        case Color.Theme.Latte:
            return latte;
        }
    }
}
