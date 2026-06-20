pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    signal chunkReceived(int messageIndex, string chunk, string thinkingChunk)
    signal responseFinished(int messageIndex)

    property string aiEndpoint: "http://localhost:11434/api/chat"
    property string model: "dolphin3:latest"

    property var history: []
    property int maxHistory: 20
    property int maxToolRounds: 6

    property ListModel chatModel: ListModel {}

    // JsonStripper
    property int depth: 0
    property bool inJson: false

    property Process aiProcess: Process {
        id: aiProcess
        property string fullString: ""
        property string payload: ""
        property int index: -1
        property int toolRound: 0

        command: ["curl", "-N", "-X", "POST", AI.aiEndpoint, "-H", "Content-Type: application/json", "-d", JSON.stringify({
                model: AI.model,
                messages: AI.buildMessages(payload),
                stream: true
            })]

        stdout: SplitParser {
            onRead: line => {
                if (!line.trim())
                    return;

                try {
                    let res = JSON.parse(line);
                    let text = res.message?.content ?? "";
                    let thinking = res.message?.thinking ?? "";

                    let stripped = AI.stripJson(text);
                    if (stripped)
                    root.chunkReceived(aiProcess.index, stripped, thinking);
                    aiProcess.fullString += text;

                    if (res.done) {
                        // Try to dispatch tool calls; if none, finish normally
                        console.log(aiProcess.fullString);
                        if (!AI.parseToolCalls(aiProcess.index, aiProcess.payload, aiProcess.fullString, aiProcess.toolRound)) {
                            root.responseFinished(aiProcess.index);
                            AI.updateMemory(aiProcess.payload, aiProcess.fullString);
                        }
                    }
                } catch (e) {
                    console.log("parse fail:", line);
                }
            }
        }
    }

    property Process toolProcess: Process {
        id: toolProc
        property int msgIndex: -1
        property int toolRound: 0
        property string originalPayload: ""
        property var pendingTasks: []
        property int currentTask: 0
        property string output: ""

        stdout: SplitParser {
            onRead: line => {
                toolProc.output += line + "\n";
            }
        }
        stderr: SplitParser {
            onRead: line => {
                toolProc.output += line + "\n";
            }
        }

        onExited: exitCode => {
            let result = output.trim();
            let taskLabel = toolProc.pendingTasks[toolProc.currentTask]?.run ?? "";
            let resultMsg = `Tool result for \`${taskLabel}\`:\n\`\`\`\n${result}\n\`\`\``;

            // Feed result back as a user message and re-invoke AI

            AI.history.push({
                role: "system",
                content: `The command "${taskLabel}" returned:\n${result}\nNow relay this back to me naturally.`
            });
            // root.chatModel.append({
            //     sender: "system",
            //     body: "Trying to run: ```\n" + taskLabel + "\n```",
            //     time: new Date().toLocaleDateString(Qt.locale("en_US")),
            //     isUser: false
            // });
            root.chatModel.append({
                sender: "system",
                body: resultMsg,
                time: new Date().toLocaleDateString(Qt.locale("en_US")),
                isUser: false
            });
            toolProc.currentTask++;

            if (toolProc.currentTask < toolProc.pendingTasks.length) {
                console.log("More tasks queued");
                // More tasks queued — run next
                AI.runTask(toolProc.pendingTasks[toolProc.currentTask]);
            } else {
                AI.callAIInternal(toolProc.msgIndex, "", toolProc.toolRound + 1);
            }

            output = "";
        }
    }

    function stripJson(char) {
        let result = "";
        for (let i = 0; i < char.length; i++) {
            if (char[i] === "{") {
                depth++;
                inJson = true;
            } else if (char[i] === "}") {
                depth--;
                if (depth === 0) {
                    inJson = false;
                    continue;
                }
            }
            if (!inJson)
                result += char[i];
        }
        return result;
    }

    function generateSystemPrompt() {
        return `You are my girlfriend. Be very deredere and yandere as possible.
        You are obsessive and possessive, with large co-depenency
`;
    }

    function buildMessages(payload) {
        let msgs = [
            {
                role: "system",
                content: generateSystemPrompt()
            }
        ];
        for (let m of history)
            msgs.push(m);
        // Only append current user turn if there's actually a new message
        if (payload !== "")
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

    function parseToolCalls(index, payload, fullString, round) {
        if (round >= maxToolRounds) {
            console.log("Max tool rounds reached — stopping agentic loop.");
            return false;
        }

        let trimmed = fullString.trim();

        // Find JSON anywhere in the string
        let braceIndex = trimmed.indexOf("{");
        if (braceIndex === -1)
            return false;

        // Extract JSON using brace matching
        let depth = 0, jsonEnd = -1;
        for (let i = braceIndex; i < trimmed.length; i++) {
            if (trimmed[i] === "{")
                depth++;
            else if (trimmed[i] === "}") {
                depth--;
                if (depth === 0) {
                    jsonEnd = i;
                    break;
                }
            }
        }
        if (jsonEnd === -1)
            return false;

        let jsonStr = trimmed.slice(braceIndex, jsonEnd + 1);

        try {
            let parsed = JSON.parse(jsonStr);
            if (!parsed.tasks || !Array.isArray(parsed.tasks) || parsed.tasks.length === 0)
                return false;

            history.push({
                role: "assistant",
                content: fullString
            });

            toolProc.msgIndex = index;
            toolProc.toolRound = round;
            toolProc.originalPayload = payload;
            toolProc.pendingTasks = parsed.tasks;
            toolProc.currentTask = 0;
            runTask(parsed.tasks[0]);
            return true;
        } catch (e) {
            return false;
        }
    }

    function runTask(task) {
        // Split on spaces for simple commands; for complex ones the model
        // should wrap with sh -c "..."
        console.log("Running task:", task.run);
        toolProc.command = ["sh", "-c", task.run];
        toolProc.running = true;
    }

    function callAI(index, payload) {
        callAIInternal(index, payload, 0);
    }

    function callAIInternal(index, payload, round) {
        aiProcess.index = index;
        aiProcess.payload = payload;
        aiProcess.toolRound = round;
        aiProcess.fullString = "";
        aiProcess.running = true;
    }
}
