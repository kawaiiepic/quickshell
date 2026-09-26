pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property var workspaces: Hyprland.workspaces
    readonly property var toplevels: Hyprland.toplevels
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property var activeToplevel: Hyprland.activeToplevel

    readonly property var focusedWindow: {
        const t = Hyprland.activeToplevel;
        if (!t)
            return null;

        const ipc = t.lastIpcObject || {};
        const appId = ipc.class || ipc.initialClass || "";

        return {
            title: t.title || ipc.title || "Desktop",
            appId: appId,
            iconSource: root.iconForClass(appId),
            address: t.address || "",
            workspaceId: t.workspace ? t.workspace.id : -1
        };
    }

    function iconForClass(appId) {
        if (!appId)
            return Quickshell.iconPath("application-x-executable");
        return Quickshell.iconPath(appId, "application-x-executable");
    }

    function iconForToplevel(toplevel) {
        if (!toplevel)
            return Quickshell.iconPath("desktop");
        const ipc = toplevel.lastIpcObject || {};
        return root.iconForClass(ipc.class || ipc.initialClass || "");
    }

    function monitorFor(screen) {
        return Hyprland.monitorFor(screen);
    }

    function workspaceOnScreen(ws, screen) {
        if (!ws)
            return false;
        if (ws.id < 0)
            return false;
        const name = String(ws.name || "");
        if (name.startsWith("special"))
            return false;

        const mon = Hyprland.monitorFor(screen);
        if (!mon)
            return true;
        return ws.monitor === mon;
    }

    function focusWorkspace(idOrName) {
        if (idOrName === undefined || idOrName === null || idOrName === "")
            return;
        Hyprland.dispatch("workspace " + idOrName);
    }

    function activateWorkspace(ws) {
        if (!ws)
            return;
        if (typeof ws.activate === "function")
            ws.activate();
        else
            Hyprland.dispatch("workspace " + (ws.name || ws.id));
    }

    function focusWindow(win) {
        if (!win)
            return;
        const addr = win.address || "";
        if (addr)
            Hyprland.dispatch("focuswindow address:" + (String(addr).startsWith("0x") ? addr : "0x" + addr));
    }

    function windowFromName(name) {
        if (!name)
            return null;

        const needle = String(name).toLowerCase();
        const list = Hyprland.toplevels.values || [];

        for (let i = 0; i < list.length; i++) {
            const t = list[i];
            const ipc = t.lastIpcObject || {};
            const cls = String(ipc.class || "").toLowerCase();
            const initial = String(ipc.initialClass || "").toLowerCase();
            const title = String(t.title || ipc.title || "").toLowerCase();

            if (cls === needle || initial === needle)
                return t;
            if (cls.includes(needle) || needle.includes(cls) && cls.length > 0)
                return t;
            if (title.includes(needle))
                return t;
        }

        return null;
    }

    function dispatch(request) {
        Hyprland.dispatch(request);
    }

    function lock() {
        Quickshell.execDetached(["sh", "-c", "qs ipc call lockscreen showLockscreen || quickshell ipc call lockscreen showLockscreen || loginctl lock-session"]);
    }

    function logout() {
        Hyprland.dispatch("exit");
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function shutdown() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
}
