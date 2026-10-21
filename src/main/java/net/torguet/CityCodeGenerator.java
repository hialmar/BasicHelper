package net.torguet;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;

public class CityCodeGenerator {
    public static void main(String[] args) throws IOException {
        CityCode cityCode = new CityCode("src/main/resources/map_ville1.s");
        cityCode.processReferenceFile();
        cityCode.pourSpecialData("src/main/resources/Ville_5.s");
        cityCode.generateCityCode("src/main/resources/map_ville5.s");
        Files.copy(Path.of("src/main/resources/map_ville5.s"),
                Path.of("/Users/torguet/.wine/drive_c/Tyrann4/map_ville5.s"), REPLACE_EXISTING);
    }
}
