package net.torguet;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Stream;

import static net.torguet.TokenCodes.*;

public class Bas2LBas {
    private final ArrayList<LineData> sortedLines;
    private final HashMap<Integer, LineData> lines;
    private final HashMap<Integer, String> lineToLabel;
    private final HashMap<String, LabelInfos> labels;
    private final HashMap<String, String> defines;
    private int currentLineNumber;
    private String fileName;
    private int nextLabel = 0;
    private String fileNameWithoutExt;

    public Bas2LBas() {
        sortedLines = new ArrayList<>();
        lines = new HashMap<>();
        labels = new HashMap<>();
        defines = new HashMap<>();
        lineToLabel = new HashMap<>();
    }


    private void addDefine(String defineName, String defineValue) {
        defines.put(defineName, defineValue);
    }

    private void addValidLineNumber(int number) {
        LineData lineData = new LineData();
        lineData.sourceNumber = number;
        lines.put(number, lineData);
    }

    private static class LabelInfos {
        int lineNumber;
    }

    private LabelInfos findLabel(String potentialLabelName) {
        return labels.get(potentialLabelName);
    }

    private String findDefine(String potentialDefine) {
        return defines.get(potentialDefine);
    }

    private static final String[] keywords =
            {
                    // 128-246: BASIC keywords
                    "END", "EDIT", "STORE", "RECALL", "TRON", "TROFF", "POP", "PLOT",
                    "PULL", "LORES", "DOKE", "REPEAT", "UNTIL", "FOR", "LLIST", "LPRINT", "NEXT", "DATA",
                    "INPUT", "DIM", "CLS", "READ", "LET", "GOTO", "RUN", "IF", "RESTORE", "GOSUB", "RETURN",
                    "REM", "HIMEM", "GRAB", "RELEASE", "TEXT", "HIRES", "SHOOT", "EXPLODE", "ZAP", "PING",
                    "SOUND", "MUSIC", "PLAY", "CURSET", "CURMOV", "DRAW", "CIRCLE", "PATTERN", "FILL",
                    "CHAR", "PAPER", "INK", "STOP", "ON", "WAIT", "CLOAD", "CSAVE", "DEF", "POKE", "PRINT",
                    "CONT", "LIST", "CLEAR", "GET", "CALL", "!", "NEW", "TAB(", "TO", "FN", "SPC(", "@",
                    "AUTO", "ELSE", "THEN", "NOT", "STEP", "+", "-", "*", "/", "^", "AND", "OR", ">", "=", "<",
                    "SGN", "INT", "ABS", "USR", "FRE", "POS", "HEX$", "&", "SQR", "RND", "LN", "EXP", "COS",
                    "SIN", "TAN", "ATN", "PEEK", "DEEK", "LOG", "LEN", "STR$", "VAL", "ASC", "CHR$", "PI",
                    "TRUE", "FALSE", "KEY$", "SCRN", "POINT", "LEFT$", "RIGHT$", "MID$"
                    // 247- : Error messages
            };

    private boolean isValidLineNumber(int lineNumber) {
        return lines.containsKey(lineNumber);
    }

    private void addLine(LineData line) {
        sortedLines.add(line);
        int lineNumber = line.sourceNumber;
        lines.put(lineNumber, line);
    }

    private void setLabel(String label, int lineNumber) {
        LabelInfos infos = labels.computeIfAbsent(label, k -> new LabelInfos());
        infos.lineNumber = lineNumber;
    }

    private void addLabel(String label) {
        labels.computeIfAbsent(label, k -> new LabelInfos());
    }

    private int searchKeyword(LineData keyword) {
        String subString = keyword.getCurrentSubString();
        for (int i = 0; i < keywords.length; i++) {
            if (subString.startsWith(keywords[i])) {
                return i;
            }
        }
        return -1;
    }

    private char processOptionalWhiteSpace(StringBuffer bufPtr, LineData lineData, boolean optimize)
    {
        char car = 1;
        while (car != 0)
        {
            car = lineData.getCurrentChar();
            if (car == ' ')  // Space
            {
                if (!optimize)
                {
                    bufPtr.append(car);
                }
                lineData.skipChar();
            }
            else
            if (car == '\t') // Tab
            {
                if (!optimize)
                {
                    bufPtr.append(car);
                }
                lineData.skipChar();
            }
            else
            {
                //ligne++;
                return car;
            }
        }
        return car;
    }

    private boolean isValidLineNumber(char car)
    {
        return (car >= '0') && (car <= '9');
    }

    private boolean isValidLabelName(char car)
    {
        return ((car >= 'a') && (car <= 'z')) ||
                ((car >= 'A') && (car <= 'Z')) ||
                (car == '_');
    }

    private String getPotentialSymbolName(LineData ligne)
    {
        StringBuilder potentialLabelName = new StringBuilder();
        char car = ligne.getCurrentChar();
        while ((isValidLabelName(car) || isValidLineNumber(car)) && (searchKeyword(ligne)<0))
        {
            potentialLabelName.append(car);
            ligne.skipChar();
            car = ligne.getCurrentChar();
        }
        return potentialLabelName.toString();
    }

    private boolean processPossibleLineNumberLabelOrDefine(StringBuffer bufPtr, LineData ligne,
                                                   boolean shouldValidateLineNumber, boolean optimize)
    {
        // Should have one or more (comma separated) numbers, variables, or labels.
        char car = processOptionalWhiteSpace(bufPtr, ligne, optimize);
        if (isValidLineNumber(car))
        {
            // Line  Number
            int lineNumber = 0;
            car = ligne.getCurrentChar();
            while (isValidLineNumber(car))
            {
                lineNumber = (lineNumber * 10) + (car - '0');
                ligne.skipChar();
                car = ligne.getCurrentChar();
            }
            if (shouldValidateLineNumber) {
                if (!isValidLineNumber(lineNumber)) {
                    System.err.printf("Can't find line number %d referred by jump instruction in file %s line number line %d\n", lineNumber, fileName, currentLineNumber);
                } else {
                    String label;
                    if (!lineToLabel.containsKey(lineNumber)) {
                        // generate a label for this line
                        label = fileNameWithoutExt + "_" + nextLabel;
                        nextLabel++;
                        lineToLabel.put(lineNumber, label);
                        addLabel(""+lineNumber);
                    } else {
                        label = lineToLabel.get(lineNumber);
                        addLabel(""+lineNumber);
                    }
                    // replace by label
                    bufPtr.append(" ").append(label).append(" ");
                }
            } else {
                // it's a normal number
                bufPtr.append(lineNumber);
            }
            return true;
        }
        else
        if (isValidLabelName(car))
        {
            // Label Name (or variable)
            String potentialLabelName = getPotentialSymbolName(ligne);

            if (!potentialLabelName.isEmpty())
            {
                LabelInfos infos = findLabel(potentialLabelName);
                if (infos != null)
                {
                    // Found the label \o/
                    bufPtr.append(" ").append(potentialLabelName).append(" ");
                }
                else
                {
                    // Did not find the label...
                    // ...maybe it's a define?
                    String findIt = findDefine(potentialLabelName);
                    if (findIt != null)
                    {
                        // Found a matching define \o/
                        // We replace the value by the actual value
                        bufPtr.append(" ").append(findIt).append(" ");
                    }
                    else
                    {
                        // Not a define either... probably a variable then...?
                        // Just write it "as is"
                        bufPtr.append(potentialLabelName);
                    }
                }
                return true;
            }
        }
        return false;
    }

    public void bas2LBas(String sourceFile, String destFile,
                         boolean optimize) throws IOException {
        boolean useExtendedBasic = false;

        currentLineNumber = 0;
        fileName = sourceFile;
        PrintStream printStream = new PrintStream(destFile);
        // Mike: Need to improve the parsing of this with a global function to split
        // a text file in separate lines.
        System.out.println("Reading file "+sourceFile);
        List<String> textData = Files.readAllLines(Path.of(sourceFile), Charset.defaultCharset());

        FirstPass result = doFirstPass(sourceFile, optimize, textData, useExtendedBasic);
        if (result == null) return;

        Path p = Path.of(fileName);
        fileNameWithoutExt = p.getFileName().toString();
        if (fileNameWithoutExt.indexOf(".") > 0) {
            fileNameWithoutExt = fileNameWithoutExt.substring(0, fileNameWithoutExt.lastIndexOf("."));
        }

        doSecondPass(result);

        System.out.println("Will write to file "+destFile);
        writeToFile(printStream);
    }

    private record FirstPass(boolean optimize, boolean useExtendedBasic) {
    }

    private FirstPass doFirstPass(String sourceFile, boolean optimize, List<String> textData, boolean useExtendedBasic) throws IOException {
        {
            //
            // First pass: Get the labels and line numbers
            //
            System.out.println("First pass");
            int lastLineNumber = 0;
            int incrementStep = 5;

            fileName = sourceFile;
            String labelName = "";

            int sourceNumber = 0;

            for(String line : textData)
            {
                LineData lineData = new LineData();
                lineData.sourceNumber = sourceNumber++;
                if (!line.isEmpty())
                {
                    char firstCar = line.charAt(0);
                    boolean startsByWhiteSpace = (firstCar == ' ') || (firstCar == '\t');

                    boolean shouldSkip = false;

                    lineData.trimmedLine = line.strip(); // (currentLine, " \t\f\v\n\r\xEF\xBB\xBF\xFF\xFE");

                    if (!lineData.trimmedLine.isEmpty())
                    {
                        String ligne = lineData.trimmedLine;
                        if (ligne.charAt(0) == '#')
                        {
                            // Preprocessor directive
                            if (ligne.startsWith("#file"))
                            {
                                //"#file font.BAS""
                                // Very approximative "get the name of the file and reset the line counter" code.
                                // Will clean up that when I will have some more time.
                                lineData.skipNChars(5);
                                fileName = lineData.getCurrentSubString();
                                lineData.sourceNumber = 0;
                            }
                            else
                            if (ligne.startsWith("#labels"))
                            {
                                //"#labels"
                                useExtendedBasic = true;
                                shouldSkip = true;
                            }
                            else
                            if (ligne.startsWith("#optimize"))
                            {
                                //"#optimize"
                                optimize = true;
                                shouldSkip = true;
                            }
                            else
                            if (ligne.startsWith("#define"))
                            {
                                //"#define DEFINE_NAME REPLACEMENT_VALUE"
                                lineData.skipNChars(7);
                                ligne = lineData.getCurrentSubString().strip();
                                String [] tab = ligne.split("[ \t]");
                                if (tab.length < 2) {
                                    System.err.println("Define missing value");
                                    return null;
                                }
                                String defineName  = tab[0].strip();
                                String defineValue = tab[1].strip();
                                LineData defineNameAsLineData = new LineData(defineName);

                                String potentialUsableName = getPotentialSymbolName(defineNameAsLineData);
                                if (!potentialUsableName.equals(defineName))
                                {
                                    int keyw = searchKeyword(defineNameAsLineData);
                                    if (keyw >= 0)
                                    {
                                        System.err.printf("Define named '%s' in file %s line number line %d contains the name of a BASIC instruction '%s'\n",
                                                defineName, fileName, lineData.sourceNumber, BasicProgram.getKeywords()[keyw]);
                                        return null;
                                    }
                                }

                                addDefine(defineName,defineValue);

                                shouldSkip = true;
                            }
                            else
                            if (ligne.startsWith("#import"))
                            {
                                // #import "path_to_the_symbols_file"
                                String importPathName = ligne.substring(7).trim();
                                // We may want to trim out things like comments, etc...
                                int startQuote = importPathName.indexOf('"');
                                int endQuote = importPathName.indexOf('"', startQuote+1);

                                if ((startQuote != 0) || (endQuote != importPathName.length()-1))
                                {
                                    System.err.printf("#import directive in file %s line number line %d should be followed by a quoted path\n", fileName, lineData.sourceNumber);
                                    return null;
                                }
                                importPathName = importPathName.substring(startQuote + 1, endQuote);  // Keep the part between the quotes
                                Path filePath = Path.of(fileName);
                                Path symbolPath = filePath.resolveSibling(importPathName);
                                List<String> symbols = Files.readAllLines(symbolPath);

                                //
                                // Load the symbol file (XA format)
                                //

                                for(String symbol : symbols)
                                {
                                    String[] tab = symbol.split(" ");
                                    int symbolAddress = Integer.parseInt(tab[0], 16);   // Address
                                    String name = tab[1];          // Name
                                    if (name.startsWith("_"))
                                    {
                                        // We are only interested in symbols with external linkage
                                        name = name.substring(1);
                                        LineData lineDataForName = new LineData(name);

                                        String potentialUsableName = getPotentialSymbolName(lineDataForName);
                                        if (potentialUsableName.equals(name))
                                        {
                                            int keyw = searchKeyword(lineDataForName);
                                            if (keyw >= 0)
                                            {
                                                System.err.printf("Define named '%s' in file %s contains the name of a BASIC instruction '%s'\n", name, importPathName, BasicProgram.getKeywords()[keyw]);
                                                return null;
                                            }
                                        }
                                        addDefine(name, ""+symbolAddress);
                                    }
                                }

                                shouldSkip = true;
                            }
                            else
                            {
                                System.err.printf("%s\r\nUnknown preprocessor directive in file %s line number line %d\n", ligne, fileName, lineData.sourceNumber);
                                return null;
                            }
                        }
                        else
                        {
                            // Standard line
                            int number = -1;
                            if (isValidLineNumber(lineData.getCurrentChar())) {
                                number = lineData.getCurrentChar() - '0';
                                lineData.skipChar();
                                while(isValidLineNumber(lineData.getCurrentChar())) {
                                    number = number*10 + lineData.getCurrentChar() - '0';
                                    lineData.skipChar();
                                }
                            }

                            if (number<0)
                            {
                                char car = ligne.charAt(0);
                                if (car != 0)
                                {
                                    char car2 = ligne.charAt(1);
                                    if ((car == '\'') || (car == ';') || ((car == '/') && (car2 == '/')))
                                    {
                                        // We accept the usual C, Assembler and BASIC comments are actual comments that do not count as normal lines
                                        // Technically we could have used a decent pre-processor, or even a full file filter, but I'm aiming at "more bangs for the bucks" approach.
                                        // If necessary we can refactor later
                                        continue;
                                    }
                                }

                                // Mike: Need to add better diagnostic here
                                if (useExtendedBasic)
                                {
                                    if (startsByWhiteSpace)
                                    {
                                        // Normal line, missing a line number, we generate one
                                        number = lastLineNumber + incrementStep;
                                    }
                                    else
                                    {
                                        // Possibly a label
                                        labelName = ligne.strip();
                                        if (labelName.isEmpty())
                                        {
                                            // Not a label, so maybe a line of basic without line number
                                            System.err.printf("Missing label information in file %s line %d\n", fileName, lineData.sourceNumber);
                                            break;
                                        }
                                        else
                                        {
                                            // Definitely a label, or something unfortunately detected as a label because of the ":" at the end :p
                                            var labelInfo = findLabel(labelName);
                                            if (labelInfo != null)
                                            {
                                                System.err.printf("Label '%s' found in file %s line %d is already defined\n", labelName, fileName, lineData.sourceNumber);
                                                break;
                                            }

                                            boolean hasSetIncrement = false;
                                            boolean hasSetNumber = false;

                                            String [] tabInc = line.substring(labelName.length()).split("[: \t]");

                                            for (String itemInc : tabInc)
                                            {
                                                String lineOrIncrement = itemInc.trim();
                                                if (!lineOrIncrement.isEmpty())
                                                {
                                                    car  = lineOrIncrement.charAt(0);
                                                    char car2 = (lineOrIncrement.length()>=2)?lineOrIncrement.charAt(1):0;
                                                    if ( (car == '\'') || (car == ';') || ((car == '/') && (car2 == '/')) )
                                                    {
                                                        // Comment
                                                        break;
                                                    }
                                                    else
                                                    if (car == '+')
                                                    {
                                                        // Increment
                                                        if (hasSetIncrement)
                                                        {
                                                            System.err.printf("Line increment value for label '%s' found in file %s line %d was already set to %d\n", labelName, fileName, lineData.sourceNumber, incrementStep);
                                                        }
                                                        lineOrIncrement = lineOrIncrement.substring(1);
                                                        try {
                                                            incrementStep = Integer.parseInt(lineOrIncrement);
                                                            hasSetIncrement = true;
                                                        } catch (NumberFormatException nfe) {
                                                            System.err.printf("Line increment value %s is not an integer\n", lineOrIncrement);
                                                        }
                                                    }
                                                    else
                                                    {
                                                        // Line number
                                                        if (hasSetNumber)
                                                        {
                                                            System.err.printf("Line number value for label '%s' found in file %s line %d was already set to %d\n", labelName, fileName, lineData.sourceNumber, lastLineNumber);
                                                        }
                                                        try {
                                                            lastLineNumber = Integer.parseInt(lineOrIncrement);
                                                        } catch (NumberFormatException nfe) {
                                                            System.err.printf("Invalid line number value '%s' for label '%s' found in file %s line %d\n", lineOrIncrement, labelName, fileName, lineData.sourceNumber);
                                                        }

                                                        setLabel(labelName, lastLineNumber);
                                                        hasSetNumber = true;
                                                    }
                                                }
                                            }

                                            if (!hasSetNumber)
                                            {
                                                setLabel(labelName, lastLineNumber + incrementStep);
                                                lineToLabel.put(lastLineNumber + incrementStep, labelName);
                                            }
                                            shouldSkip = true;
                                        }
                                    }
                                }
                                else
                                {
                                    System.err.printf("Missing line number in file %s line %d\n", fileName, lineData.sourceNumber);
                                    break;
                                }
                            }
                            else
                            {
                                // We have a valid line number, if we have a pending label, record it
                                if (!labelName.isEmpty())
                                {
                                    setLabel(labelName,number);
                                    labelName = "";
                                }
                                lineData.trimmedLine = lineData.getCurrentSubString().strip();
                            }
                            if (number >= 0)
                            {
                                lineData.basicNumber = number;
                                lastLineNumber = number;
                                addValidLineNumber(number);
                            }
                        }
                        if (!shouldSkip)
                        {
                            // No need to add labels as actual lines to parse
                            addLine(lineData);
                        }
                    }
                }
            }
        }
        return new FirstPass(optimize, useExtendedBasic);
    }

    private void doSecondPass(FirstPass result) {
        System.out.println("Second pass");
        //
        // Second pass: Create labels
        //
        int previousLineNumber;
        previousLineNumber = -1;

        for(LineData lineData : sortedLines)
        {
            String currentLine = lineData.trimmedLine;
            currentLineNumber = lineData.sourceNumber;
            lineData.pos = 0;

            if (lineData.basicNumber <= previousLineNumber)
            {
                System.err.printf("BASIC line number %d in file %s line number line %d is smaller than the previous line %d\n", lineData.basicNumber, fileName, currentLineNumber, previousLineNumber);
            }
            previousLineNumber = lineData.basicNumber;

            if (!currentLine.isEmpty())
            {
                if (currentLine.charAt(0) != '#')
                {
                    // Standard line
                    StringBuffer buffer = new StringBuffer();

                    boolean isComment      = false;
                    boolean isQuotedString = false;
                    boolean isData         = false;
                    boolean isOnGoToOrSub  = false;

                    while (lineData.getCurrentChar() == ' ' &&
                            lineData.pos < currentLine.length())
                        lineData.skipChar();

                    while (lineData.pos < currentLine.length())
                    {
                        char car = lineData.getCurrentChar();
                        char car2 = lineData.getNextChar();

                        if (isComment)
                        {
                            char value = lineData.getCurrentChar();
                            lineData.skipChar();
                            if (!result.optimize())
                            {
                                buffer.append(value);
                            }
                        }
                        else
                        if (isQuotedString)
                        {
                            if (car == '"')
                            {
                                isQuotedString = false;
                            }
                            if (car == '~')
                            {
                                // Special control code
                                if ( (car2>=96) && (car2 <= 'z') )  // 96=arobase ('a'-1)
                                {
                                    buffer.append(car);
                                    buffer.append(car2);
                                    lineData.skipNChars(2);
                                }
                                else
                                if ((car2 >= '@') && (car2 <= 'Z'))
                                {
                                    buffer.append(car);      // ESCAPE
                                    buffer.append(car2);    // Actual control code
                                    lineData.skipNChars(2);
                                }
                                else
                                {
                                    System.err.printf("The sequence '~%c' in file %s line number line %d is not a valid escape sequence\n", car2, fileName, currentLineNumber);
                                }
                            }
                            else
                            {
                                buffer.append(lineData.getCurrentChar());
                                lineData.skipChar();
                            }
                        }
                        else
                        if (isData)
                        {
                            // Data is a very special system where nothing is tokenized, so you can have FOR or THEN, they will be interpreted as normal strings
                            if (car == ':')
                            {
                                isData = false;
                            }
                            else
                            if (car == '"')
                            {
                                isQuotedString = true;
                            }
                            else
                            {
                                int savedPosition = buffer.length();
                                processPossibleLineNumberLabelOrDefine(buffer, lineData, false, result.optimize());
                                processOptionalWhiteSpace(buffer, lineData, result.optimize());
                                if (buffer.length() != savedPosition)
                                {
                                    continue;
                                }
                            }
                            buffer.append(lineData.getCurrentChar());
                            lineData.skipChar();
                        }
                        else
                        {
                            processOptionalWhiteSpace(buffer, lineData, result.optimize());

                            int keyw = searchKeyword(lineData);
                            if (keyw == Token_REM.ordinal() || (lineData.getCurrentChar() == '\''))
                            {
                                // REM
                                isComment = true;
                                if (result.optimize())
                                {
                                    continue;
                                }
                            }
                            else
                            if (keyw == Token_DATA.ordinal())
                            {
                                // DATA
                                isData = true;
                            }
                            else
                            if (keyw == Token_ON.ordinal())
                            {
                                // ON ... GOTO or ON ... GOSUB
                                isOnGoToOrSub = true;
                            }

                            car  = lineData.getCurrentChar();
                            car2 = lineData.getNextChar();

                            if (car == '"')
                            {
                                isQuotedString = true;
                            }
                            else
                            if ( (car == 0xA7) || ((car == 0xC2) && (car2 == 0xA7)) )
                            {
                                //
                                // Special '§' symbol that get replaced by the current line number.
                                // Appears in encodings as either "C2 A7" or "A7"
                                //
                                buffer.append(lineData.basicNumber);
                                lineData.skipChar();
                                if (car == 0xC2)
                                {
                                    // Need to skip two characters...
                                    lineData.skipChar();
                                }
                                continue;
                            }
                            else
                            if (car == '(')
                            {
                                buffer.append(car);
                                lineData.skipChar();
                                // Open parenthesis
                                processPossibleLineNumberLabelOrDefine(buffer, lineData, false, result.optimize());
                                continue;
                            }
                            else
                            if (car == ',')
                            {
                                buffer.append(car);
                                lineData.skipChar();
                                // comma
                                processPossibleLineNumberLabelOrDefine(buffer, lineData, isOnGoToOrSub, result.optimize());
                                continue;
                            }

                            if (keyw >= 0)
                            {
                                buffer.append(keywords[keyw]);
                                lineData.skipNChars(keywords[keyw].length());
                                processOptionalWhiteSpace(buffer, lineData, result.optimize());

                                //
                                // Note: This bunch of tests should be replaced by actual flags associated to keywords to define their behavior:
                                // - Can be followed by a line number
                                // - Can be the complementary part of an expression (and thus should not be part of a symbol)
                                // - ...
                                //
                                if ((keyw == Token_GOTO.ordinal())
                                    || (keyw == Token_GOSUB.ordinal())
                                    || (keyw == Token_RESTORE.ordinal())
                                    || (keyw == Token_CALL.ordinal())
                                    || (keyw == Token_SymbolEqual.ordinal())
                                    || (keyw == Token_SymbolMinus.ordinal())
                                    || (keyw == Token_SymbolPlus.ordinal())
                                    || (keyw == Token_SymbolMultiply.ordinal())
                                    || (keyw == Token_SymbolDivide.ordinal())
                                    || (keyw == Token_TO.ordinal())
                                    || (keyw == Token_THEN.ordinal())
                                    || (keyw == Token_ELSE.ordinal()))
                                {
                                    if ((keyw == Token_THEN.ordinal()) || (keyw == Token_ELSE.ordinal()))
                                    {
                                        if (searchKeyword(lineData) >= 0)
                                        {
                                            // THEN and ELSE instructions can be followed directly by a line number... but they can also have an instruction like PRINT
                                            processOptionalWhiteSpace(buffer, lineData, result.optimize());
                                            continue;
                                        }
                                    }
                                    // Should have one or more (comma separated) numbers, variables, or labels.
                                    boolean shouldValidateLineNumber = ! ( (keyw == Token_SymbolEqual.ordinal()) ||
                                            (keyw == Token_RESTORE.ordinal()) ||
                                            (keyw == Token_CALL.ordinal()) ||
                                            (keyw == Token_SymbolMinus.ordinal()) ||
                                            (keyw == Token_SymbolPlus.ordinal()) ||
                                            (keyw == Token_SymbolMultiply.ordinal()) ||
                                            (keyw == Token_TO.ordinal()) ||
                                            (keyw == Token_SymbolDivide.ordinal()));
                                    processPossibleLineNumberLabelOrDefine(buffer, lineData, shouldValidateLineNumber, result.optimize());
                                    processOptionalWhiteSpace(buffer, lineData, result.optimize());
                                }
                            }
                            else
                            {
                                if (!processPossibleLineNumberLabelOrDefine(buffer, lineData, false, result.optimize()))
                                {
                                    buffer.append(lineData.getCurrentChar());
                                    lineData.skipChar();
                                }
                            }
                        }
                    }

                    if (result.optimize())
                    {
                        // Remove any white space at the end of the line
                        // while (((bufPtr-1) > (lineStart+4)) && (bufPtr[-1] == ' '))
                        while(buffer.length()>4 && buffer.charAt(buffer.length()-1) ==' ')
                        {
                            buffer.deleteCharAt(buffer.length()-1);
                        }
                    }
                    if (buffer.isEmpty())
                    {
                        // If the line is empty, we add a REM ...
                        buffer.append("REM");
                    }

                    // rewrite the line
                    lineData.trimmedLine = buffer.toString();

                }
            }
        }
    }

    private void writeToFile(PrintStream printStream) {

        //
        // Save file
        //
        System.out.println("Writing to file");
        printStream.println("#labels");

        for(LineData lineData : sortedLines) {
            if (lineToLabel.containsKey(lineData.basicNumber)) {
                printStream.println(lineToLabel.get(lineData.basicNumber));
            }
            printStream.println(" "+lineData.trimmedLine);
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length == 2) {
            Bas2LBas bas2LBas = new Bas2LBas();
            bas2LBas.bas2LBas(args[0], args[1], false);
        } else {
            try (Stream<Path> paths = Files.walk(Paths.get("src/main/resources"))) {
                paths
                        .filter(Files::isRegularFile)
                        .forEach((file) -> {
                            String name = file.toString();
                            if (name.endsWith(".bas") && !name.endsWith("L.bas")) {
                                try {
                                    Bas2LBas bas2LBas = new Bas2LBas();
                                    bas2LBas.bas2LBas(file.toString(), file + "_L.bas", false);
                                } catch (IOException e) {
                                    throw new RuntimeException(e);
                                }
                            }
                        });
            }
        }
    }

}