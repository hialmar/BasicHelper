package net.torguet;

import java.util.List;

public class MultiLineData {
    public List<String> lines;
    public String firstLabel;

    public MultiLineData(List<String> lines, String firstLabel) {
        this.lines = lines;
        this.firstLabel = firstLabel;
    }

    public void replaceNextLines(LabelDescriptor firstDesc, LabelDescriptor secondDesc, int linesToReplace, int linesToAdd) {
        int lineInFirst = firstDesc.lineNumberInMultiLine() + 1;
        int lineInSecond = secondDesc.lineNumberInMultiLine() + 1;
        while(linesToReplace>0) {
            lines.remove(lineInFirst);
            lines.add(lineInFirst, secondDesc.multiLine().get(lineInSecond));
            lineInFirst++;
            lineInSecond++;
            linesToReplace--;
        }
        while(linesToAdd>0) {
            lines.add(lineInFirst, secondDesc.multiLine().get(lineInSecond));
            lineInFirst++;
            lineInSecond++;
            linesToAdd--;
        }
    }

    public void removeLines(int pos, int linesToRemove) {
        while(linesToRemove>0) {
            lines.remove(pos);
            linesToRemove--;
        }
    }

    public void copyLines(int pos, int copyStart, int linesToCopy) {
        while(linesToCopy>0) {
            lines.add(pos, lines.get(copyStart));
            copyStart++;
            linesToCopy--;
        }
    }
}
