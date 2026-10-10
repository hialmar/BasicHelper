package net.torguet;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.stream.Stream;

public class BatGenerator {
    static String configFormat = """
@ECHO OFF

::
:: Set the build parameters
::
SET OSDKDEBUG=-g1
SET OSDKCOMP=-O1
SET OSDKADDR=$600
SET OSDKNAME=%s
SET OSDKTAPNAME=%s
SET OSDKFILE=%s
""";

    static String buildFormat = """
:%s

CALL osdk_config_%s.bat
CALL %%OSDK%%\\bin\\make.bat %%OSDKFILE%%
%%OSDK%%\\bin\\MemMap.exe -s30 build\\symbols build\\%s.htm %%OSDKNAME%% %%OSDK%%\\documentation\\documentation.css
Copy BUILD\\symbols BUILD\\symbols_%s

::Goto GestionSymbols
            """;

    static String buildEnd = """
            
:GestionSymbols
Call sed -i.bak s/\\\\/\\//g BUILD\\symbols_ext
Call sed -i.bak s/c:\\//\\/Users\\/torguet\\/.wine\\/drive_c\\//g BUILD\\symbols_ext
Call sed -i.bak s/C:\\//\\/Users\\/torguet\\/.wine\\/drive_c\\//g BUILD\\symbols_ext


Copy sed.exe ased.exe
Copy sedoric_io.s asedoric_io.s

Del sed*

Copy ased.exe sed.exe\s
Copy asedoric_io.s sedoric_io.s\s

Goto Tap2dsk
:Tap2dsk

pause

%%OSDK%%\\bin\\tap2dsk -n"   Tyrann IV" -i"DIR" %s t4_prog.dsk

pause

%%OSDK%%\\bin\\old2mfm t4_prog.dsk

GOTO End

::
:: Outputs an error message
::
:ErCfg
ECHO == ERROR ==
ECHO The Oric SDK was not configured properly
ECHO You should have a OSDK environment variable setted to the location of the SDK
IF "%%OSDKBRIEF%%"=="" PAUSE
GOTO End


:End
pause
            """;
    static String buildBegin = """
@ECHO OFF

::
:: Initial check.
:: Verify if the SDK is correctly configurated
::
IF "%OSDK%"=="" GOTO ErCfg
          
            """;

    public static void main(String[] args) throws Exception {
        ArrayList<String> names = new ArrayList<>();
        try (Stream<Path> paths = Files.walk(Paths.get("src/main/resources"))) {
            paths
                    .filter(Files::isRegularFile)
                    .forEach((file) -> {
                        String name = String.valueOf(file.getFileName());
                        if (name.endsWith(".s") && !name.endsWith(".S")) {
                            name = name.substring(0,name.length()-2);
                            System.out.println(name);
                            names.add(name);
                            String config = String.format(configFormat, name, name, name);
                            try {
                                Files.writeString(Path.of("osdk_config_"+name+".bat"), config, StandardOpenOption.CREATE);
                            } catch (IOException e) {
                                throw new RuntimeException(e);
                            }
                        }
                    });
        }

        Files.writeString(Path.of("osdk_build.bat"), buildBegin, StandardOpenOption.TRUNCATE_EXISTING);
        StringBuilder listOfBuiltFiles = new StringBuilder();

        for(String name : names) {
            String build = String.format(buildFormat, name, name, name, name);
            Files.writeString(Path.of("osdk_build.bat"), build, StandardOpenOption.APPEND);
            listOfBuiltFiles.append("BUILD\\").append(name).append(".tap ");
        }

        String end = String.format(buildEnd, listOfBuiltFiles);
        Files.writeString(Path.of("osdk_build.bat"), end, StandardOpenOption.APPEND);

    }
}

