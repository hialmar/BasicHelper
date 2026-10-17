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

        manageCityDefine(fileName);

        hideKeysAndChests(specificFile);

        manageChestTexts(specificFile);
        // ATTENTION, les Labels dans texts ont tous bougé.

        manageAffText(specificFile);
        // ATTENTION, les Labels dans affText ont tous bougé.

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

    private void hideKeysAndChests(AsmFile specificFile) {
        LabelDescriptor cle1 = referenceFile.getLabelDescriptor("suite_init1");
        LabelDescriptor line0 = specificFile.getLabelDescriptor("_L00");
        TileDescriptor keyTile1 = mapData.searchTile("$54", line0.lineNumberInMultiLine());
        if (cle1 != null && keyTile1 != null)
            initVars.hideTile(cle1, keyTile1);
        System.out.println("key1: "+keyTile1);
        TileDescriptor keyTile2 = mapData.searchTile("$55", line0.lineNumberInMultiLine());
        System.out.println("key2: "+keyTile2);
        LabelDescriptor cle2 = referenceFile.getLabelDescriptor("suite_init2");
        if (cle2 != null && keyTile2 != null)
            initVars.hideTile(cle2, keyTile2);
        TileDescriptor chestTile = mapData.searchTile("$57", line0.lineNumberInMultiLine());
        System.out.println("Mdp: "+chestTile);
        LabelDescriptor chest1 = referenceFile.getLabelDescriptor("suite_init2_2");
        if (chest1 != null && chestTile != null)
            initVars.hideTile(chest1, chestTile);
        System.out.println("Chests");
        chestTile = mapData.searchTile("$63", line0.lineNumberInMultiLine());
        System.out.println("Chest: " + chestTile);
        LabelDescriptor chest2 = referenceFile.getLabelDescriptor("suite_init3");
        if (chest2 != null && chestTile != null) {
            initVars.hideTile(chest2, chestTile);
            manageChestUpdate(0, chestTile);
            chestTile = mapData.searchTile("$63", chestTile.lineDataOffset);
            System.out.println("Chest: " + chestTile);
            LabelDescriptor chest3 = referenceFile.getLabelDescriptor("suite_init4");
            if (chest3 != null && chestTile != null) {
                initVars.hideTile(chest3, chestTile);
                manageChestUpdate(1, chestTile);
                chestTile = mapData.searchTile("$63", chestTile.lineDataOffset);
                System.out.println("Chest: " + chestTile);
                LabelDescriptor chest4 = referenceFile.getLabelDescriptor("suite_init5");
                if (chest4 != null && chestTile != null) {
                    initVars.hideTile(chest4, chestTile);
                    manageChestUpdate(2, chestTile);
                    chestTile = mapData.searchTile("$63", chestTile.lineDataOffset);
                    System.out.println("Chest: " + chestTile);
                    LabelDescriptor chest5 = referenceFile.getLabelDescriptor("suite_init6");
                    if (chest5 != null && chestTile != null) {
                        initVars.hideTile(chest5, chestTile);
                        manageChestUpdate(3, chestTile);
                    }
                }
            }
        }
    }

    private void manageChestUpdate(int chestNumber, TileDescriptor chestTile) {
        String label = switch (chestNumber) {
            case 0 -> "suite_overflow";
            case 1 -> "suite_coffre1";
            case 2 -> "suite_coffre2";
            default -> "suite_coffre3";
        };
        LabelDescriptor chest = referenceFile.getLabelDescriptor(label);
        if (chest != null) {
            int lIndex = chestTile.lineLabel.indexOf("L");
            if (lIndex>0) {
                String numLigne = chestTile.lineLabel.substring(lIndex + 1);
                int num = Integer.parseInt(numLigne);
                String cmpLine = affText.lines.get(chest.lineNumberInMultiLine() + 2);
                int hashIndex = cmpLine.indexOf('#');
                if (hashIndex>0) {
                    String newCmpLine = cmpLine.substring(0, hashIndex+1) + num;
                    affText.lines.add(chest.lineNumberInMultiLine() + 2, newCmpLine);
                    affText.lines.remove(chest.lineNumberInMultiLine() + 3);
                }
            }
        }
    }

    private void manageAffText(AsmFile specificFile) {
        LabelDescriptor animalerieOld = referenceFile.getLabelDescriptor("t_animalerie_1");
        LabelDescriptor animalerie = specificFile.getLabelDescriptor("t_animalerie_1");
        if(animalerieOld != null && animalerie == null) {
            LabelDescriptor labelHerbo = referenceFile.getLabelDescriptor("herboriste_");
            LabelDescriptor labelAnimalerie = referenceFile.getLabelDescriptor("animalerie_");
            affText.copyLines(labelHerbo.lineNumberInMultiLine()+3, labelAnimalerie.lineNumberInMultiLine()+3, 1);
            affText.removeLines(labelHerbo.lineNumberInMultiLine()+4,1);
            affText.removeLines(labelAnimalerie.lineNumberInMultiLine(), 19);
        }

        LabelDescriptor legatOld = referenceFile.getLabelDescriptor("t_legat_1");
        LabelDescriptor legat = specificFile.getLabelDescriptor("t_legat_1");
        if(legatOld != null && legat == null) {
            LabelDescriptor suiteGarde = referenceFile.getLabelDescriptor("suite_garde");
            LabelDescriptor suiteLegat = referenceFile.getLabelDescriptor("suite_legat");
            affText.copyLines(suiteGarde.lineNumberInMultiLine()-1, suiteLegat.lineNumberInMultiLine()-1, 1);
            affText.removeLines(suiteGarde.lineNumberInMultiLine(),1);
            legat = referenceFile.getLabelDescriptor("legat_");
            affText.removeLines(legat.lineNumberInMultiLine(), 59);
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
    }

    private void manageChestTexts(AsmFile specificFile) {
        LabelDescriptor coffre2Old = referenceFile.getLabelDescriptor("t_coffre_2");
        LabelDescriptor coffre2 = specificFile.getLabelDescriptor("t_coffre_2");
        if(coffre2Old != null && coffre2 != null) {
            texts.replaceNextLines(coffre2, coffre2Old, 2, 3);
        }
    }

    private void manageCityDefine(String fileName) {
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
