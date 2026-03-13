package net.torguet;

import java.util.ArrayList;
import java.util.HashMap;

public class BasicProgram {
    private final ArrayList<LineData> sortedLines;
    private final HashMap<String, LineData> lines;
    private int firstLine;
    private int lastLine;

    public void addDefine(String defineName, String defineValue) {
        defines.put(defineName, defineValue);
    }

    public void addValidLineNumber(int number) {
        LineData lineData = new LineData();
        lineData.sourceNumber = number;
        lines.put(""+number, lineData);
    }

    public class LabelInfos {
        int lineNumber;
        ArrayList<String> referencedLines;
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

    public BasicProgram() {
        sortedLines = new ArrayList<>();
        lines = new HashMap<>();
        labels = new HashMap<>();
        defines = new HashMap<>();
        firstLine = -1;
        lastLine = -1;
    }

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
            for (String line : infos.referencedLines) {
                replaceLineNumber(Integer.parseInt(line), oldLine, newLine);
            }
        }
    }

    private void replaceLineNumber(int line, int oldLine, int newLine) {
        String rewrittenLine = "";
        LineData lineToModify = lines.get(line);

    }

    private int computeLineNumber(String line) {
        // remove leading spaces
        int start = 0;
        while (line.charAt(start) == ' ')
            start++;
        int firstWhiteSpace = line.indexOf(' ', start);
        if (firstWhiteSpace == -1) return -1;
        String lineNumber = line.substring(start, firstWhiteSpace);
        return Integer.parseInt(lineNumber);
    }

    private void computeLabels(LineData line, int lineNumber) {
        String[] tab = line.trimmedLine.split("[ :']");
        for (int i = 0; i < tab.length; i++) {
            String s = tab[i];
            System.out.println(s);
            switch (s.toUpperCase()) {
                case "THEN":
                case "ELSE":
                case "GOTO":
                case "GOSUB":
                    try {
                        String next = tab[i + 1];
                        int nextLine = Integer.parseInt(next);
                        addLabel("" + nextLine, lineNumber);
                        i++;
                    } catch (Exception e) {
                        e.printStackTrace();
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
        infos.referencedLines.add("" + lineNumber);
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
