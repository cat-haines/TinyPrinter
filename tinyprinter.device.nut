// Hardware Configuration
local serial = hardware.uart57;
serial.configure(19200, 8, PARITY_NONE, 1, NO_CTSRTS);

function writeLine(n = 1) {
    for(local i = 0; i < n; i++) {
        serial.write('\r')
        serial.write('\n')
    }
}
function writeString(a) {
    foreach(c in a) {
        serial.write(c);
    }
}

function printInfo(info) {
    writeString(info);
    writeLine(4);
}

function prepText(text) {
    local newLine = "\r\n"
    local textParts = split(text, " \r\n");
    
    local textToPrint = "";
    local lineLength = 0;
    
    foreach (part in textParts) {
        // if it's going to wrap
        if (lineLength + part.len() > 32) {
            // if the current work if > 32 characters
            if (part.len() > 32) {
                textToPrint += newLine + part + newLine;
                linelength = 0;
            } else {
                textToPrint += newLine + part + " ";
                lineLength = part.len() + 1;
            }
        } else {
            textToPrint += part + " ";
            lineLength += part.len() + 1;
        }
    }
    textToPrint += "\r\n";
    
    return textToPrint;
}

const LINE_LENGTH = 32;

bootMessage <- "--------------------------------\r\n"
bootMessage += "--- Electric Imp TinyPrinter ---\r\n"
bootMessage += "--------------------------------\r\n"
bootMessage += "\r\n\r\n";

// Hardware Configuration
local serial = hardware.uart57;
serial.configure(19200, 8, PARITY_NONE, 1, NO_CTSRTS);

function writeString(a) {
    foreach(c in a) {
        serial.write(c);
    }
}

function writeLine(n = 1) {
    for(local i = 0; i < n; i++) {
        serial.write('\r')
        serial.write('\n')
    }
}

function printTweet(tweet) {
    local text = prepText("\"" + tweet.text + "\"");
    
    local user = "- " + tweet.user;
    for (local i = user.len(); i < LINE_LENGTH; i++) user = " " + user;
    
    writeString(text);
    writeLine();
    writeString(user);
    writeLine(4)
}

function printInfo(info) {
    writeString(prepText(info));
    writeLine(4);
}

agent.on("tweet", printTweet);
agent.on("info", printInfo)

imp.configure("Printer", [], []);
agent.send("coldboot", null);
writeString(bootMessage);
