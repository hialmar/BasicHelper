package net.torguet;

import java.util.ArrayList;
import java.util.HashMap;

public class BasicProgram {
    private final ArrayList<String> sortedLines;
    private final HashMap<Integer, String> lines;
    private int firstLine;
    private int lastLine;
    private final HashMap<Integer, ArrayList<Integer>> labels;

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
        int firstWhiteSpace = line.indexOf(' ');
        if (firstWhiteSpace == -1) return -1;
        String lineNumber = line.substring(0, firstWhiteSpace);
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
}
