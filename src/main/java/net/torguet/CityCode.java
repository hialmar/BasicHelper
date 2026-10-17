package net.torguet;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

public class CityCode {
    private MultiLineData start;
    private MultiLineData initVars;
    private MultiLineData checkAround;
    private MultiLineData implCar;
    private MultiLineData affText;
    private MultiLineData whyNoScroll;
    private MultiLineData printCityName;
    private MultiLineData mapData;
    private MultiLineData tiles;
    private MultiLineData tilePointers;
    private MultiLineData texts;
    private MultiLineData addedSymbols;
    private MultiLineData charRedefine;

    private final AsmFile referenceFile;

    private ArrayList<MultiLineData>  multiLineDataArrayList;

    public CityCode(String fileName){
        referenceFile = new AsmFile(fileName);
    }

    public void processReferenceFile() throws IOException {
        referenceFile.processFile();

        start = referenceFile.get("#define");
        initVars = referenceFile.get("init_div_var");
        checkAround = referenceFile.get("chck_around");
        implCar = referenceFile.get("impl_car");
        affText = referenceFile.get("aff_text");
        whyNoScroll = referenceFile.get("why_no_scoll");
        printCityName = referenceFile.get("prt_nom_ville");
        mapData = referenceFile.get("_L00");
        tiles = referenceFile.get("_t00");
        tilePointers = referenceFile.get("ptr_t");
        texts = referenceFile.get("t_portail_1");
        addedSymbols = referenceFile.get("t_coffre_3");
        charRedefine = referenceFile.get("dta_car_redef_p1");
    }

    public void pourSpecialData(String fileName) throws IOException {
        AsmFile specificFile = new AsmFile(fileName);
        specificFile.processFile();

        printCityName = specificFile.get("prt_nom_ville");
        mapData = specificFile.get("_L00");
        tiles = specificFile.get("_t00");
        tilePointers = specificFile.get("ptr_t");
        charRedefine = specificFile.get("dta_car_redef_p1");
        texts = specificFile.get("t_portail_1");

        String define = start.lines.getFirst();
        int numberIndex = define.indexOf('0');
        if (numberIndex > 0) {
            int underScoreIndex = fileName.lastIndexOf("_");
            int dotIndex = fileName.lastIndexOf(".");
            if (underScoreIndex > 0 && dotIndex > 0) {
                int cityNumber = Integer.parseInt(fileName.substring(underScoreIndex+1, dotIndex));
                cityNumber = (cityNumber-1)*2;
                define = define.substring(0, numberIndex) + cityNumber;
                start.lines.removeFirst();
                start.lines.addFirst(define);
            }
        }

        LabelDescriptor coffre2Old = referenceFile.getLabelDescriptor("t_coffre_2");
        LabelDescriptor coffre2 = specificFile.getLabelDescriptor("t_coffre_2");
        if(coffre2Old != null && coffre2 != null) {
            texts.replaceNextLines(coffre2, coffre2Old, 2, 3);
        }

        LabelDescriptor voleurOld = referenceFile.getLabelDescriptor("t_voleur_1");
        LabelDescriptor voleur = specificFile.getLabelDescriptor("t_voleur_1");
        if(voleurOld != null && voleur == null) {
            LabelDescriptor suiteCle = referenceFile.getLabelDescriptor("suite_clef");
            LabelDescriptor suiteVoleur = referenceFile.getLabelDescriptor("suite_voleur");
            affText.copyLines(suiteCle.lineNumberInMultiLine()-1, suiteVoleur.lineNumberInMultiLine()-1, 1);
            affText.removeLines(suiteCle.lineNumberInMultiLine(),1);
            voleur = referenceFile.getLabelDescriptor("voleur_");
            affText.removeLines(voleur.lineNumberInMultiLine(), 40);
        }

        multiLineDataArrayList = new ArrayList<>();
        multiLineDataArrayList.add(start);
        multiLineDataArrayList.add(initVars);
        multiLineDataArrayList.add(checkAround);
        multiLineDataArrayList.add(implCar);
        multiLineDataArrayList.add(affText);
        multiLineDataArrayList.add(whyNoScroll);
        multiLineDataArrayList.add(printCityName);
        multiLineDataArrayList.add(mapData);
        multiLineDataArrayList.add(tiles);
        multiLineDataArrayList.add(tilePointers);
        multiLineDataArrayList.add(texts);
        multiLineDataArrayList.add(addedSymbols);
        multiLineDataArrayList.add(charRedefine);
    }

    public void generateCityCode(String fileName) throws IOException {
        try (PrintWriter printWriter = new PrintWriter(new FileWriter(fileName))) {
            for(MultiLineData multiLineData : this.multiLineDataArrayList) {
                if (multiLineData == null)
                    continue;
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
}
