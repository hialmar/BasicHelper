package net.torguet;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class AsmFile {
    private final String fileName;
    private final ArrayList<MultiLineData> lineDataArrayList = new ArrayList<>();

    public AsmFile(String fileName) {
        this.fileName = fileName;
    }

    @Override
    public String toString() {
        return "AsmFile{" +
                "fileName='" + fileName + '\'' +
                ", lineDataArrayList=" + lineDataArrayList +
                '}';
    }

    public void processFile() throws IOException {
        List<String> lines = Files.readAllLines(Path.of(fileName));

        ArrayList<String> currentElement = new ArrayList<>();
        String firstLabel = null;

        for(String line : lines) {
            line = manageEmptyLines(line);

            if (line.isEmpty()) {
                // empty line
                if (currentElement.size()>1) {
                    MultiLineData lineData = new MultiLineData(currentElement, firstLabel);
                    lineDataArrayList.add(lineData);
                }
                firstLabel = null;
                currentElement = new ArrayList<>();
            } else if (line.startsWith(" ") || line.startsWith("\t")) {
                // normal line
                currentElement.add(line);
            } else if (line.startsWith(";")) {
                // comment
                currentElement.add(line);
            } else {
                // label
                if (firstLabel == null)
                    firstLabel = line;
                currentElement.add(line);
            }
        }
    }

    private String manageEmptyLines(String line) {
        for(int i=0; i<line.length(); i++) {
            if (line.charAt(i)!=' ' && line.charAt(i)!='\t')
                // not empty
                return line;
        }
        return "";
    }

    public static void main(String[] args) throws IOException {
        AsmFile asmFile = new AsmFile("src/main/resources/Ville_3.s");
        asmFile.processFile();
        System.out.println(asmFile);
    }
}
