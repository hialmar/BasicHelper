package net.torguet;

public class TileDescriptor {
    public String lineLabel;
    public int offset;
    public int lineDataOffset;

    public TileDescriptor(String lineLabel, int offset, int lineDataOffset) {
        this.lineLabel = lineLabel;
        this.offset = offset;
        this.lineDataOffset = lineDataOffset;
    }

    public String getLineLabel() {
        return lineLabel;
    }

    public int getOffset() {
        return offset;
    }

    public int getLineDataOffset() {
        return lineDataOffset;
    }

    @Override
    public String toString() {
        return "TileDescriptor{" +
                "lineLabel='" + lineLabel + '\'' +
                ", offset=" + offset +
                ", lineDataOffset=" + lineDataOffset +
                '}';
    }
}
