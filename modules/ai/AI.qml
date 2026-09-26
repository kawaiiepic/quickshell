import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

ShellRoot {
    property string aiEndpoint: "http://localhost:11434/api/chat"
    property string model: "qwen3:8b"

    property var history: []
    property int maxHistory: 20
    property string wakeWord: "naomi"

    property Process process: Process {
        stdout:SplitParser {
            onRead: line => {
                console.log(line)
            }
        }
    }

    property Process whisper: Process {
        running: false
        command: ["whisper-stream", "-m", "/home/mia/Documents/quickshell/modules/ai/ggml-tiny.bin"]
        stdout: SplitParser {
            onRead: line => {
                line = line.trim();

                if (line.length === 0 || line.includes("[BLANK_AUDIO]"))
                    return;

                const lower = line.toLowerCase();
                const cleaned = lower.replace(wakeWord, "").trim();

                if (!cleaned.length)
                    return;

                console.log("sending to ai:", cleaned);
                callAI(cleaned);
            }
        }
    }

    function showNotification(text) {
        console.log("Attempting at: " + text);
        process.command = ["sh", "-c", `/home/mia/Documents/quickshell/assets/scripts/say.sh ${text}`];
        process.running = true;
    }

    function generateSystemPrompt() {
        return `
            You are my AI girlfriend, we talk occasionally, you live inside my computer.
`;
    }

    function buildMessages(payload) {
        let msgs = [];

        msgs.push({
            role: "system",
            content: generateSystemPrompt()
        });

        for (let i = 0; i < history.length; i++) {
            msgs.push(history[i]);
        }

        msgs.push({
            role: "user",
            content: payload
        });

        return msgs;
    }

    function updateMemory(userMsg, assistantMsg) {
        history.push({
            role: "user",
            content: userMsg
        });
        history.push({
            role: "assistant",
            content: assistantMsg
        });

        if (history.length > maxHistory * 2) {
            history.splice(0, 2);
        }
    }

    function callAI(payload) {
        console.log("AI event:", payload);

        let xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    let res = JSON.parse(xhr.responseText);

                    let text = "";
                    if (res.message && res.message.content) {
                        text = res.message.content;
                    }

                    console.log("AI:", text);

                    if (text.length > 0) {
                        showNotification(text);
                        updateMemory(payload, text);
                    }
                } catch (e) {
                    showNotification("AI parse error");
                }
            }
        };

        xhr.open("POST", aiEndpoint);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.send(JSON.stringify({
            model: model,
            messages: buildMessages(payload),
            stream: false
        }));
    }

    Component.onCompleted: {
        console.log("AI shell started");
    }
}
