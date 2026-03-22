package net.torguet;

import static org.junit.jupiter.api.Assertions.*;

class LineDataTest {
    String line;
    LineData lineData;

    @org.junit.jupiter.api.BeforeEach
    void setUp() {
        line = "ON X GOTO X,Y,Z";
        lineData = new LineData(line);
    }

    @org.junit.jupiter.api.Test
    void skipChar() {
        for(int i=0; i<line.length(); i++) {
            lineData.skipChar();
            assertEquals(i+1,lineData.pos);
        }
    }

    @org.junit.jupiter.api.Test
    void skipNChars() {
        lineData.skipNChars(10);
        assertEquals(10,lineData.pos);
    }

    @org.junit.jupiter.api.Test
    void getNextChar() {
        char c = lineData.getNextChar();
        assertEquals('N', c);
        lineData.skipNChars(line.length()-1);
        c = lineData.getNextChar();
        assertEquals(0, c);
    }

    @org.junit.jupiter.api.Test
    void getCurrentChar() {
        char c = lineData.getCurrentChar();
        assertEquals('O', c);
        lineData.skipNChars(line.length());
        c = lineData.getCurrentChar();
        assertEquals(0, c);
    }

    @org.junit.jupiter.api.Test
    void getCurrentSubString() {
        assertEquals(line, lineData.getCurrentSubString());
        lineData.skipChar();
        assertEquals(line.substring(1), lineData.getCurrentSubString());
    }
}