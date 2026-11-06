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

    public TileDescriptor searchTile(String tile, int startLine) {
        if(startLine + 2 > lines.size())
            return null;
        String prevLine = lines.get(startLine);
        startLine++;
        String currentLine = lines.get(startLine);
        startLine++;
        while(startLine<lines.size()) {
            int offset = currentLine.indexOf(tile);
            if (offset > 0) {
                String label = AsmFile.getLabel(prevLine);
                int firstDollar = currentLine.indexOf('$');
                offset = (offset - firstDollar)/4;
                return new TileDescriptor(label, offset, startLine);
            }
            if(startLine + 2 > lines.size())
                return null;
            prevLine = lines.get(startLine);
            startLine++;
            currentLine = lines.get(startLine);
        }
        return null;
    }

    public void hideTile(LabelDescriptor cle1, TileDescriptor keyTile1) {
        // sta is just above
        String staLine = lines.get(cle1.lineNumberInMultiLine()-1);
        int underScoreIndex = staLine.indexOf('_');
        int commaIndex = staLine.indexOf(',');
        if (underScoreIndex>0 && commaIndex>0) {
            String newStaLine = staLine.substring(0, underScoreIndex) +
                    keyTile1.lineLabel +
                    staLine.substring(commaIndex);
            lines.remove(cle1.lineNumberInMultiLine()-1);
            lines.add(cle1.lineNumberInMultiLine()-1, newStaLine);
        }
        // ldx is 3 lines above
        String ldxLine = lines.get(cle1.lineNumberInMultiLine()-3);
        int hashIndex = ldxLine.indexOf('#');
        if (hashIndex>0) {
            String newLdxLine = ldxLine.substring(0, hashIndex+1) + keyTile1.offset;
            lines.remove(cle1.lineNumberInMultiLine()-3);
            lines.add(cle1.lineNumberInMultiLine()-3, newLdxLine);
        }
    }
}
