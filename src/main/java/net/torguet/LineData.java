package net.torguet;

public class LineData {

    public String trimmedLine;
    public int sourceNumber;
    public int basicNumber;
    public int pos;

    public LineData() {
        trimmedLine = "";
        sourceNumber = -1;
        basicNumber = -1;
        pos = 0;
    }

    public LineData(String line) {
        trimmedLine = line;
        sourceNumber = -1;
        basicNumber = -1;
        pos = 0;
    }

    public void skipChar() {
        pos++;
    }

    public void skipNChars(int nb) {
        pos+=nb;
    }

    public char getNextChar() {
        if (pos+1 >= trimmedLine.length())
            return 0;
        return trimmedLine.charAt(pos+1);
    }

    public char getCurrentChar() {
        if (pos >= trimmedLine.length())
            return 0;
        return trimmedLine.charAt(pos);
    }

    public String getCurrentSubString() {
        return trimmedLine.substring(pos);
    }

    @Override
    public String toString() {
        return trimmedLine;
    }
}