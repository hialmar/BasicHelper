package net.torguet;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class AsmFile {
    private final String fileName;
    private final ArrayList<MultiLineData> multiLineDataArrayList = new ArrayList<>();
    private final HashMap<String, MultiLineData> multiLineDataHashMap = new HashMap<>();

    public AsmFile(String fileName) {
        this.fileName = fileName;
    }

    @Override
    public String toString() {
        return "AsmFile{" +
                "fileName='" + fileName + '\'' +
                ", lineDataArrayList=" + multiLineDataHashMap +
                '}';
    }

    public void processFile() throws IOException {
        List<String> lines = Files.readAllLines(Path.of(fileName));

        ArrayList<String> currentElement = new ArrayList<>();
        String firstLabel = null;
        boolean afterLabel = true;

        int i = 0;
        String line = lines.get(i);
        String nextLine = lines.get(i+1);
        while(i < lines.size()) {
            line = manageEmptyLines(line);
            if (line.startsWith(" ") || line.startsWith("\t")) {
                // normal line
                currentElement.add(line);
            } else if (line.startsWith(";")) {
                if (afterLabel &&
                        (line.startsWith(";---") || line.startsWith("; ---") ||
                                line.startsWith(";***")  || line.startsWith("; ***")))
                {
                    // changing part
                    if (nextLine.startsWith(";") && currentElement.size()>1) {
                        MultiLineData lineData = new MultiLineData(currentElement, firstLabel);
                        multiLineDataHashMap.put(firstLabel, lineData);
                        multiLineDataArrayList.add(lineData);
                        firstLabel = null;
                        afterLabel = false;
                        currentElement = new ArrayList<>();
                    }
                }
                // comment
                currentElement.add(line);
            } else if (!line.isEmpty()) {
                // label
                if (firstLabel == null) {
                    // get only the label
                    int min = line.indexOf(';');
                    int whiteSpace = line.indexOf(' ');
                    if (whiteSpace>0) {
                        if (min < 0) {
                            min = whiteSpace;
                        } else if (whiteSpace<min) {
                            min = whiteSpace;
                        }
                    }
                    int tab = line.indexOf('\t');
                    if (tab>0) {
                        if (min < 0) {
                            min = tab;
                        } else if (tab<min) {
                            min = tab;
                        }
                    }
                    if (min>0) {
                        firstLabel = line.substring(0,min);
                    } else {
                        firstLabel = line;
                    }
                }
                currentElement.add(line);
                afterLabel = true;
            }

            i++;
            if (i<lines.size())
                line = lines.get(i);
            if (i+1<lines.size())
                nextLine = lines.get(i+1);
        }

        // last part
        if (currentElement.size()>1) {
            MultiLineData lineData = new MultiLineData(currentElement, firstLabel);
            multiLineDataHashMap.put(firstLabel, lineData);
            multiLineDataArrayList.add(lineData);
        }
    }

    public void writeToFile(String newFileName) throws IOException {
        try (PrintWriter printWriter = new PrintWriter(new FileWriter(newFileName))) {
            for(MultiLineData multiLineData : this.multiLineDataArrayList) {
                printWriter.println(";--- <<< First Label "+multiLineData.firstLabel+" >>>");
                for(String line : multiLineData.lines) {
                    printWriter.println(line);
                }
                printWriter.println();
                printWriter.println();
                printWriter.println();
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
        asmFile.writeToFile("src/main/resources/Ville_3_processed.s");

/*
        AsmFile asmFile = new AsmFile("src/main/resources/map_ville1.s");
        asmFile.processFile();
        asmFile.writeToFile("src/main/resources/map_ville1_processed.s");
 */
    }

    public MultiLineData get(String label) {
        return this.multiLineDataHashMap.get(label);
    }
}
