package net.torguet;

import javax.sound.sampled.Line;
import java.util.ArrayList;
import java.util.HashMap;

public class BasicProgram {
    private String name;
    private final ArrayList<LineData> sortedLines;
    private final HashMap<String, LineData> lines;
    private int firstLine;
    private int lastLine;
    private int nextLabelId;
    private int nextDefineId;

    public BasicProgram(String name) {
        this.name = name;
        // remove extension
        int ext = this.name.indexOf('.');
        if (ext != -1) {
            this.name = this.name.substring(0,ext);
        }
        sortedLines = new ArrayList<>();
        lines = new HashMap<>();
        labels = new HashMap<>();
        defines = new HashMap<>();
        firstLine = -1;
        lastLine = -1;
        nextLabelId = 0;
    }

    public void addDefine(String defineName, String defineValue) {
        defines.put(defineName, defineValue);
    }

    public void addValidLineNumber(int number) {
        LineData lineData = new LineData();
        lineData.sourceNumber = number;
        lines.put(""+number, lineData);
    }

    public void replaceLinesByLabels() {
        labels.forEach((name, infos) -> {
            replaceByLabel(name, infos);
        });

        removeLineNumbers();
    }

    private void removeLineNumbers() {
        for(LineData line : sortedLines) {
            if(isValidLineNumber(line.trimmedLine.charAt(0))) {
                int i =0;
                while(isValidLineNumber(line.trimmedLine.charAt(i))) {
                    i++;
                }
                line.trimmedLine = line.trimmedLine.substring(i);
            }
        }
    }

    private boolean isValidLineNumber(char car)
    {
        if ((car >= '0') && (car <= '9')) return true;
        return false;
    }

    private void replaceByLabel(String name, LabelInfos infos) {
        // check if it's a line number
        if (isValidLineNumber(name.charAt(0))) {
            String label = this.name + "_" + nextLabelId;
            nextLabelId++;
            try {
                int number = Integer.parseInt(name);
                for(int refLine : infos.referencedLines) {
                    LineData line = lines.get(""+refLine);
                    replaceLineNumber(line, name, label);
                }
            } catch (NumberFormatException e) {
                System.out.println("Not really a line number");
            }
        }
    }

    private void replaceLineNumber(LineData line, String name, String label) {
        String [] tab = line.trimmedLine.split("[ \t']");
        String newLine = "";
        // remove the line number
        for(int i=1; i< tab.length; i++) {
            String tok = tab[i];
            if (tok.equals(name)) {
                newLine += " "+label;
            } else {
                newLine += " "+tok;
            }
        }
        line.trimmedLine = newLine;
    }

    public class LabelInfos {
        int lineNumber;
        ArrayList<Integer> referencedLines;

        @Override
        public String toString() {
            return "LabelInfos{" +
                    "lineNumber=" + lineNumber +
                    ", referencedLines=" + referencedLines +
                    '}';
        }
    }

    private final HashMap<String, LabelInfos> labels;

    private final HashMap<String, String> defines;

    public LabelInfos findLabel(String potentialLabelName) {
        return labels.get(potentialLabelName);
    }

    public String findDefine(String potentialDefine) {
        return defines.get(potentialDefine);
    }


    private static final String[] keywords =
            {
                    // 128-246: BASIC keywords
                    "END", "EDIT", "STORE", "RECALL", "TRON", "TROFF", "POP", "PLOT",
                    "PULL", "LORES", "DOKE", "REPEAT", "UNTIL", "FOR", "LLIST", "LPRINT", "NEXT", "DATA",
                    "INPUT", "DIM", "CLS", "READ", "LET", "GOTO", "RUN", "IF", "RESTORE", "GOSUB", "RETURN",
                    "REM", "HIMEM", "GRAB", "RELEASE", "TEXT", "HIRES", "SHOOT", "EXPLODE", "ZAP", "PING",
                    "SOUND", "MUSIC", "PLAY", "CURSET", "CURMOV", "DRAW", "CIRCLE", "PATTERN", "FILL",
                    "CHAR", "PAPER", "INK", "STOP", "ON", "WAIT", "CLOAD", "CSAVE", "DEF", "POKE", "PRINT",
                    "CONT", "LIST", "CLEAR", "GET", "CALL", "!", "NEW", "TAB(", "TO", "FN", "SPC(", "@",
                    "AUTO", "ELSE", "THEN", "NOT", "STEP", "+", "-", "*", "/", "^", "AND", "OR", ">", "=", "<",
                    "SGN", "INT", "ABS", "USR", "FRE", "POS", "HEX$", "&", "SQR", "RND", "LN", "EXP", "COS",
                    "SIN", "TAN", "ATN", "PEEK", "DEEK", "LOG", "LEN", "STR$", "VAL", "ASC", "CHR$", "PI",
                    "TRUE", "FALSE", "KEY$", "SCRN", "POINT", "LEFT$", "RIGHT$", "MID$"
                    // 247- : Error messages
            };



    public int getFirstLine() {
        return firstLine;
    }

    public int getLastLine() {
        return lastLine;
    }

    public ArrayList<LineData> getSortedLines() {
        System.out.println(lines);
        System.out.println(labels);
        return sortedLines;
    }

    public boolean isValidLineNumber(int lineNumber) {
        return lines.containsKey(lineNumber);
    }

    public void addLine(LineData line) {
        sortedLines.add(line);
        line.sourceNumber = computeLineNumber(line.trimmedLine, line);
        int lineNumber = line.sourceNumber;
        if (firstLine == -1 || lineNumber < firstLine) firstLine = lineNumber;
        if (lastLine == -1 || lineNumber > lastLine) lastLine = lineNumber;
        lines.put("" + lineNumber, line);
        computeLabels(line, lineNumber);
    }

    public void moveCode(int newStartLine) {

    }

    public void compressLines() {

    }

    private String renumberLine(String line, int newLine) {
        int firstWhiteSpace = line.indexOf(' ');
        if (firstWhiteSpace == -1) return null;
        return newLine + " " + line.substring(firstWhiteSpace);
    }

    private void recomputeLabel(int oldLine, int newLine) {
        LabelInfos infos = labels.get("" + oldLine);
        if (infos != null && infos.referencedLines != null) {
            for (int line : infos.referencedLines) {
                replaceLineNumber(line, oldLine, newLine);
            }
        }
    }

    private void replaceLineNumber(int line, int oldLine, int newLine) {
        String rewrittenLine = "";
        LineData lineToModify = lines.get(line);

    }

    private int computeLineNumber(String line, LineData lineData) {
        if (line == null)
            return -1;
        // remove leading spaces
        int start = 0;
        while (!isValidLineNumber(line.charAt(start)))
            start++;
        int firstNonNumber = start;
        while(isValidLineNumber(line.charAt(firstNonNumber))
            firstNonNumber++;
        if (firstNonNumber == -1) return -1;
        String lineNumber = line.substring(start, firstNonNumber);
        lineData.sourceNumber = Integer.parseInt(lineNumber);
        lineData.trimmedLine = line.substring(firstNonNumber);
        return lineData.sourceNumber;
    }

    private void computeLabels(LineData line, int lineNumber) {
        if (line.trimmedLine == null || line.trimmedLine.length() == 0)
            return;
        // find number
        int startOfNumber = 0;
        int endOfNumber = 0;
        int lineLength = line.trimmedLine.length();
        while(startOfNumber<lineLength) {
            // skip non number
            while (startOfNumber < lineLength && !isValidLineNumber(line.trimmedLine.charAt(startOfNumber)))
                startOfNumber++;
            // parse the whole number
            endOfNumber = startOfNumber;
            int lineNumberOrNumber = line.trimmedLine.charAt(endOfNumber) - '0';
            while(endOfNumber < lineLength && isValidLineNumber(line.trimmedLine.charAt(endOfNumber))) {
                endOfNumber++;
                lineNumberOrNumber = 10*lineNumberOrNumber + line.trimmedLine.charAt(endOfNumber) - '0';
            }
            // check what was before that number
            if (startOfNumber-2>=0) {
                String twoChars = line.trimmedLine.substring(startOfNumber - 2, startOfNumber);
                if (twoChars.equalsIgnoreCase("TO")) {
                    if (startOfNumber - 4 >= 0) {
                        // could be TO or GOTO
                        String fourChars = line.trimmedLine.substring(startOfNumber - 4, startOfNumber);
                        if (fourChars.equalsIgnoreCase("GOTO")) {
                            addLabel("" + lineNumberOrNumber, lineNumber);
                        }
                    } else {
                        // it's a TO
                        addDefine(name + "_D_" + this.nextDefineId, "" + lineNumberOrNumber);
                        this.nextDefineId++;
                    }
                } else if (twoChars.equalsIgnoreCase("UB")) {
                    // could be GOSUB
                    String fiveChars = line.trimmedLine.substring(startOfNumber - 5, startOfNumber);
                    if (fiveChars.equalsIgnoreCase("GOSUB")) {
                        addLabel("" + lineNumberOrNumber, lineNumber);
                    }
                } else if (twoChars.equalsIgnoreCase("EN")) {
                    // could be THEN
                }
            }
        }

    }

    public void setLabel(String label, int lineNumber) {
        LabelInfos infos = labels.computeIfAbsent(label, k -> new LabelInfos());
        infos.lineNumber = lineNumber;
    }

    public void addLabel(String label, int lineNumber) {
        LabelInfos infos = labels.computeIfAbsent(label, k -> new LabelInfos());
        if (infos.referencedLines == null)
            infos.referencedLines = new ArrayList<>();
        infos.referencedLines.add(lineNumber);
    }

    public static String[] getKeywords() {
        return keywords;
    }

    public static int searchKeyword(String keyword) {
        for (int i = 0; i < keywords.length; i++) {
            if (keywords[i].equalsIgnoreCase(keyword)) {
                return i;
            }
        }
        return -1;
    }
}
