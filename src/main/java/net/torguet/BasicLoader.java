package net.torguet;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import static net.torguet.BasicProgram.searchKeyword;

public class BasicLoader {
    private final BufferedReader bufferedReader;
    private final BasicProgram basicProgram;
    private int currentLineNumber;
    private String fileName;

    public BasicLoader(String fileName) throws Exception {
        currentLineNumber = 0;
        this.fileName = fileName;
        bufferedReader = new BufferedReader(new FileReader(fileName));
        Path p = Path.of(fileName);
        basicProgram = new BasicProgram(p.getFileName().toString());
    }

    public void readProgram() throws Exception {
        String line = "";
        while (line != null) {
            LineData lineData = new LineData();
            line = lineData.trimmedLine = bufferedReader.readLine();
            if (line != null && line.length() > 1)
                basicProgram.addLine(lineData);
        }
        bufferedReader.close();
    }

    public BasicProgram getBasicProgram() {
        return basicProgram;
    }


    private static void tap2Bas(String inputFile, String destFile) throws IOException {
        FileInputStream fileInputStream = new FileInputStream(inputFile);
        PrintStream fileOutputStream = null;
        if ((destFile != null) && (!destFile.isEmpty()))
        {
            fileOutputStream = new PrintStream(new FileOutputStream(destFile));
        }
        if (fileOutputStream == null)
        {
            System.err.println("Can't open file for writing\n");
            return;
        }

        byte [] buffer = fileInputStream.readAllBytes();

        if (buffer[0]!=0x16 || buffer[3]!=0x24)
        {
            System.err.println("Not an Oric file");
        }
        if (buffer[6]!=0)
        {
            System.err.println("Not a BASIC file");
        }
        int i=13;
        while (buffer[i++]>0) {

        }
        while (buffer[i]!=0 || buffer[i+1]!=0)
        {
            i+=2;
            int lineNumber = buffer[i];
            if (lineNumber < 0) {
                lineNumber = 256 + lineNumber;
            }
            int lineNumberHigh = buffer[i+1];
            if (lineNumberHigh < 0) {
                lineNumberHigh = 256 + lineNumberHigh;
            }
            lineNumberHigh = lineNumberHigh << 8;
            lineNumber = lineNumber+lineNumberHigh;
            fileOutputStream.print(""+lineNumber+" ");
            i+=2;
            int car;
            while (buffer[i]!=0)
            {
                car=buffer[i];
                if (car < 0)
                    car = 256 + car;

                if (car<128)
                    fileOutputStream.print((char) car);
                else
                if (car < 247)
                {
                    fileOutputStream.print(BasicProgram.getKeywords()[car - 128]);
                }
                else
                {
                    // Probably corrupted listing
                    // 247 : NEXT WITHOUT FOR
                    fileOutputStream.print("CORRUPTED_ERROR_CODE");
                    fileOutputStream.print(car);
                }
                i++;
            }
            i++;
            fileOutputStream.write('\r');
            fileOutputStream.write('\n');
        }

        fileOutputStream.close();
    }


    public static void main(String[] args) throws Exception {
        BasicLoader.tap2Bas("src/main/resources/intro.tap", "src/main/resources/intro2.bas");
        BasicLoader basicLoader = new BasicLoader("src/main/resources/intro2.bas");
        basicLoader.readProgram();
        BasicProgram basicProgram = basicLoader.getBasicProgram();
        basicProgram.replaceLinesByLabels();
        basicProgram.getSortedLines().forEach(System.out::println);
    }
}
