package net.torguet;

import java.util.ArrayList;
import java.util.HashMap;

public class BasicProgram {
    private final ArrayList<String> sortedLines;
    private final HashMap<Integer, String> lines;
    private int firstLine;
    private int lastLine;
    private final HashMap<Integer, ArrayList<Integer>> labels;


    private static final String [] keywords =
    {
        // 128-246: BASIC keywords
        "END","EDIT","STORE","RECALL","TRON","TROFF","POP","PLOT",
                "PULL","LORES","DOKE","REPEAT","UNTIL","FOR","LLIST","LPRINT","NEXT","DATA",
                "INPUT","DIM","CLS","READ","LET","GOTO","RUN","IF","RESTORE","GOSUB","RETURN",
                "REM","HIMEM","GRAB","RELEASE","TEXT","HIRES","SHOOT","EXPLODE","ZAP","PING",
                "SOUND","MUSIC","PLAY","CURSET","CURMOV","DRAW","CIRCLE","PATTERN","FILL",
                "CHAR","PAPER","INK","STOP","ON","WAIT","CLOAD","CSAVE","DEF","POKE","PRINT",
                "CONT","LIST","CLEAR","GET","CALL","!","NEW","TAB(","TO","FN","SPC(","@",
                "AUTO","ELSE","THEN","NOT","STEP","+","-","*","/","^","AND","OR",">","=","<",
                "SGN","INT","ABS","USR","FRE","POS","HEX$","&","SQR","RND","LN","EXP","COS",
                "SIN","TAN","ATN","PEEK","DEEK","LOG","LEN","STR$","VAL","ASC","CHR$","PI",
                "TRUE","FALSE","KEY$","SCRN","POINT","LEFT$","RIGHT$","MID$"
        // 247- : Error messages
    };





    public BasicProgram() {
        sortedLines = new ArrayList<>();
        lines = new HashMap<>();
        labels = new HashMap<>();
        firstLine = -1;
        lastLine = -1;
    }

    public int getFirstLine() {
        return firstLine;
    }

    public int getLastLine() {
        return lastLine;
    }

    public ArrayList<String> getSortedLines() {
        System.out.println(lines);
        System.out.println(labels);
        return sortedLines;
    }

    public void addLine(String line) {
        sortedLines.add(line);
        int lineNumber = computeLineNumber(line);
        if (firstLine == -1 || lineNumber < firstLine) firstLine = lineNumber;
        if (lastLine == -1 || lineNumber > lastLine) lastLine = lineNumber;
        lines.put(lineNumber, line);
        computeLabels(line, lineNumber);
    }

    public void moveCode(int newStartLine) {

    }

    public void compressLines() {

    }

    private String renumberLine(String line, int newLine) {
        int firstWhiteSpace = line.indexOf(' ');
        if (firstWhiteSpace == -1) return null;
        return newLine+" "+line.substring(firstWhiteSpace);
    }

    private void recomputeLabel(int oldLine, int newLine) {
        ArrayList<Integer> list = labels.get(oldLine);
        if (list != null) {
            for(int line : list) {
                replaceLineNumber(line, oldLine, newLine);
            }
        }
    }

    private void replaceLineNumber(int line, int oldLine, int newLine) {
        String rewrittenLine = "";
        String lineToModify = lines.get(line);

    }

    private int computeLineNumber(String line) {
        // remove leading spaces
        int start=0;
        while(line.charAt(start)==' ')
            start++;
        int firstWhiteSpace = line.indexOf(' ', start);
        if (firstWhiteSpace == -1) return -1;
        String lineNumber = line.substring(start, firstWhiteSpace);
        return Integer.parseInt(lineNumber);
    }

    private void computeLabels(String line, int lineNumber) {
        String [] tab = line.split("[ :']");
        for(int i=0; i< tab.length; i++) {
            String s = tab[i];
            System.out.println(s);
            switch(s.toUpperCase()) {
                case "THEN":
                case "ELSE":
                case "GOTO":
                case "GOSUB":
                    try {
                        String next = tab[i + 1];
                        int nextLine = Integer.parseInt(next);
                        addLabel(nextLine, lineNumber);
                        i++;
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
            }
        }
    }

    private void addLabel(int label, int lineNumber) {
        ArrayList<Integer> list = labels.computeIfAbsent(label, k -> new ArrayList<>());
        list.add(lineNumber);
    }

    public static String[] getKeywords() {
        return keywords;
    }
}
