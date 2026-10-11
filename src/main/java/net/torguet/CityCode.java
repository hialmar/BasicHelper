package net.torguet;

import java.io.IOException;

public class CityCode {
    private MultiLineData start;
    private MultiLineData initVars;
    private MultiLineData checkAround;
    private MultiLineData tuileSpeciale;
    private MultiLineData implCar;
    private MultiLineData affText;
    private MultiLineData whyNoScroll;
    private MultiLineData noPasaran;
    private MultiLineData printCityName;
    private MultiLineData mapData;
    private MultiLineData ptrLines;
    private MultiLineData tiles;
    private MultiLineData texts;
    private MultiLineData header;
    private MultiLineData nameData;
    private MultiLineData charRedefine;

    private AsmFile referenceFile;
    private AsmFile specificFile;

    public CityCode(String fileName){
        referenceFile = new AsmFile(fileName);
    }

    public void processReferenceFile() throws IOException {
        referenceFile.processFile();

        start = referenceFile.get("#define");
        initVars = referenceFile.get("init_div_var");
        checkAround = referenceFile.get("chck_around");
        tuileSpeciale = referenceFile.get("tuile_speciale");
        implCar = referenceFile.get("impl_car");
        affText = null;
    }

    public void pourSpecialData(String fileName) throws IOException {
        specificFile = new AsmFile(fileName);
        specificFile.processFile();
    }
}
