package net.torguet;

import java.io.IOException;

public class CityCodeGenerator {
    public static void main(String[] args) throws IOException {
        CityCode cityCode = new CityCode("src/main/resources/map_ville1.s");
        cityCode.processReferenceFile();
        cityCode.pourSpecialData("src/main/resources/Ville_4.s");
        cityCode.generateCityCode("src/main/resources/map_ville4.s");
    }
}
