package net.torguet;

import java.io.BufferedReader;
import java.io.FileReader;

public class BasicLoader {
    private final BufferedReader bufferedReader;
    private final BasicProgram basicProgram;

    public BasicLoader(String fileName) throws Exception {
        bufferedReader = new BufferedReader(new FileReader(fileName));
        basicProgram = new BasicProgram();
    }

    public void readProgram() throws Exception {
        String line = "";
        while (line != null) {
            line = bufferedReader.readLine();
            if (line != null)
                basicProgram.addLine(line);
        }
        bufferedReader.close();
    }

    public BasicProgram getBasicProgram() {
        return basicProgram;
    }

    public static void main(String[] args) throws Exception {
        BasicLoader basicLoader = new BasicLoader("src/main/resources/intro.bas");
        basicLoader.readProgram();
        BasicProgram basicProgram = basicLoader.getBasicProgram();
        basicProgram.getSortedLines().forEach(System.out::println);
    }
}
