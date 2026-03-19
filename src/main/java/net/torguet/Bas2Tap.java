package net.torguet;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static net.torguet.TokenCodes.*;

public class Bas2Tap {
    private final ArrayList<LineData> sortedLines;
    private final HashMap<String, LineData> lines;
    private final HashMap<String, LabelInfos> labels;
    private final HashMap<String, String> defines;
    private int firstLine;
    private int lastLine;
    private BufferedReader bufferedReader;
    private int currentLineNumber;
    private String fileName;


    public Bas2Tap() {
        sortedLines = new ArrayList<>();
        lines = new HashMap<>();
        labels = new HashMap<>();
        defines = new HashMap<>();
        firstLine = -1;
        lastLine = -1;
    }


    public void addDefine(String defineName, String defineValue) {
        defines.put(defineName, defineValue);
    }

    public void addValidLineNumber(int number) {
        LineData lineData = new LineData();
        lineData.sourceNumber = number;
        lines.put(""+number, lineData);
    }

    public class LabelInfos {
        int lineNumber;
        ArrayList<String> referencedLines;
    }

    public LabelInfos findLabel(String potentialLabelName) {
        return labels.get(potentialLabelName);
    }

    public String findDefine(String potentialDefine) {
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


    public int getFirstLine() {
        return firstLine;
    }

    public int getLastLine() {
        return lastLine;
    }

    public ArrayList<LineData> getSortedLines() {
        System.out.println(lines);
        System.out.println(labels);
        return sortedLines;
    }

    public boolean isValidLineNumber(int lineNumber) {
        return lines.containsKey(lineNumber);
    }

    public void addLine(LineData line) {
        sortedLines.add(line);
        int lineNumber = line.sourceNumber;
        if (firstLine == -1 || lineNumber < firstLine) firstLine = lineNumber;
        if (lastLine == -1 || lineNumber > lastLine) lastLine = lineNumber;
        lines.put("" + lineNumber, line);
    }

    public void setLabel(String label, int lineNumber) {
        LabelInfos infos = labels.computeIfAbsent(label, k -> new LabelInfos());
        infos.lineNumber = lineNumber;
    }

    public void addLabel(String label, int lineNumber) {
        LabelInfos infos = labels.computeIfAbsent(label, k -> new LabelInfos());
        if (infos.referencedLines == null)
            infos.referencedLines = new ArrayList<>();
        infos.referencedLines.add("" + lineNumber);
    }

    public String[] getKeywords() {
        return keywords;
    }

    public int searchKeyword(LineData keyword) {
        String subString = keyword.getCurrentSubString();
        for (int i = 0; i < keywords.length; i++) {
            if (subString.startsWith(keywords[i])) {
                return i;
            }
        }
        return -1;
    }

    private static void tap2Bas(String inputFile, String destFile) throws IOException {
        FileInputStream fileInputStream = new FileInputStream(inputFile);
        PrintStream fileOutputStream = null;
        if ((destFile != null) && (!destFile.isEmpty()))
        {
            fileOutputStream = new PrintStream(new FileOutputStream(destFile));
        }
        if (fileOutputStream == null)
        {
            System.err.println("Can't open file for writing\n");
            return;
        }

        byte [] buffer = fileInputStream.readAllBytes();

        if (buffer[0]!=0x16 || buffer[3]!=0x24)
        {
            System.err.println("Not an Oric file");
        }
        if (buffer[6]!=0)
        {
            System.err.println("Not a BASIC file");
        }
        int i=13;
        while (buffer[i++]>0) {

        }
        while (buffer[i]!=0 || buffer[i+1]!=0)
        {
            i+=2;
            int lineNumber = buffer[i];
            if (lineNumber < 0) {
                lineNumber = 256 + lineNumber;
            }
            int lineNumberHigh = buffer[i+1];
            if (lineNumberHigh < 0) {
                lineNumberHigh = 256 + lineNumberHigh;
            }
            lineNumberHigh = lineNumberHigh << 8;
            lineNumber = lineNumber+lineNumberHigh;
            fileOutputStream.print(""+lineNumber+" ");
            i+=2;
            int car;
            while (buffer[i]!=0)
            {
                car=buffer[i];
                if (car < 0)
                    car = 256 + car;

                if (car<128)
                    fileOutputStream.print((char) car);
                else
                if (car < 247)
                {
                    fileOutputStream.print(BasicProgram.getKeywords()[car - 128]);
                }
                else
                {
                    // Probably corrupted listing
                    // 247 : NEXT WITHOUT FOR
                    fileOutputStream.print("CORRUPTED_ERROR_CODE");
                    fileOutputStream.print(car);
                }
                i++;
            }
            i++;
            fileOutputStream.write('\r');
            fileOutputStream.write('\n');
        }

        fileOutputStream.close();
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
        if ((car >= '0') && (car <= '9')) return true;
        return false;
    }

    private boolean isValidLabelName(char car)
    {
        if (((car >= 'a') && (car <= 'z')) ||
                ((car >= 'A') && (car <= 'Z')) ||
                (car == '_'))  return true;
        return false;
    }

    private String getPotentialSymbolName(LineData ligne)
    {
        String potentialLabelName = "";
        char car = ligne.getCurrentChar();
        while ((isValidLabelName(car) || isValidLineNumber(car)) && (searchKeyword(ligne)<0))
        {
            potentialLabelName += car;
            ligne.skipChar();
            car = ligne.getCurrentChar();
        }
        return potentialLabelName;
    }

    boolean processPossibleLineNumberLabelOrDefine(StringBuffer bufPtr, LineData ligne,
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
                bufPtr.append(car);
                ligne.skipChar();
                car = ligne.getCurrentChar();
            }
            if (shouldValidateLineNumber && ! isValidLineNumber(lineNumber))
            {
                System.err.printf("Can't find line number %d referred by jump instruction in file %s line number line %d", lineNumber, fileName, currentLineNumber);
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
                String valueToWrite;

                LabelInfos infos = findLabel(potentialLabelName);
                if (infos != null)
                {
                    // Found the label \o/
                    // We replace the value by the stringified line number
                    int lineNumber = infos.lineNumber;
                    bufPtr.append(" "+lineNumber+" ");
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
                        String defineValue = findIt;
                        bufPtr.append(defineValue);
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

    private void bas2Tap(String sourceFile, String destFile,
                         boolean autoRun, boolean useColor, boolean optimize) throws IOException {
        int end, adr;

        boolean useExtendedBasic = false;

        DataOutputStream dataOutputStream = new DataOutputStream(new FileOutputStream(destFile));
        StringBuffer stringBuffer = new StringBuffer();
        // Mike: Need to improve the parsing of this with a global function to split
        // a text file in separate lines.
        List<String> textData = Files.readAllLines(Path.of(sourceFile), Charset.defaultCharset());
        if (textData == null)
        {
            System.err.println("Unable to load source file");
            return;
        }

        {
            //
            // First pass: Get the labels and line numbers
            //
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
                                    return;
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
                                        System.err.printf("Define named '%s' in file %s line number line %d contains the name of a BASIC instruction '%s'",
                                                defineName, fileName, lineData.sourceNumber, BasicProgram.getKeywords()[keyw]);
                                        return;
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
                                int startQuote = ligne.indexOf('"', 0);
                                int endQuote = ligne.indexOf('"', startQuote);

                                if ((startQuote != 0) || (endQuote != ligne.length()))
                                {
                                    System.err.printf("#import directive in file %s line number line %d should be followed by a quoted path", fileName, lineData.sourceNumber);
                                    return;
                                }
                                importPathName = importPathName.substring(startQuote + 1, endQuote - 1);  // Keep the part between the quotes

                                List<String> symbols = Files.readAllLines(Path.of(importPathName));

                                //
                                // Load the symbol file (XA format)
                                //
                                if (symbols == null)
                                {
                                    System.err.printf("Unable to load symbol file '%s'", importPathName);
                                    return;
                                }

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
                                                System.err.printf("Define named '%s' in file %s contains the name of a BASIC instruction '%s'", name, importPathName, BasicProgram.getKeywords()[keyw]);
                                                return;
                                            }
                                        }
                                        addDefine(name, ""+symbolAddress);
                                    }
                                }

              /*
              const char* ptrDefineName = defineName.c_str();
              std::string potentialUsableName = GetPotentialSymbolName(ptrDefineName);
              if (potentialUsableName != defineName)
              {
                int keyw = search_keyword(ptrDefineName);
                if (keyw >= 0)
                {
                  ShowError("Define named '%s' in file %s line number line %d contains the name of a BASIC instruction '%s'", defineName.c_str(), m_CurrentFileName.c_str(), lineData.sourceNumber, keywords[keyw]);
                }
              }


              m_Defines[defineName] = defineValue;
              */
                                shouldSkip = true;
                            }
                            else
                            {
                                System.err.printf("%s\r\nUnknown preprocessor directive in file %s line number line %d", ligne, fileName, lineData.sourceNumber);
                                return;
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
                                            System.err.printf("Missing label information in file %s line %d", fileName, lineData.sourceNumber);
                                            break;
                                        }
                                        else
                                        {
                                            // Definitely a label, or something unfortunately detected as a label because of the ":" at the end :p
                                            var labelInfo = findLabel(labelName);
                                            if (labelInfo != null)
                                            {
                                                System.err.printf("Label '%s' found in file %s line %d is already defined", labelName, fileName, lineData.sourceNumber);
                                                break;
                                            }

                                            boolean hasSetIncrement = false;
                                            boolean hasSetNumber = false;

                                            while (!line.isEmpty())
                                            {
                                                String [] tabInc = line.split("[: \t]");
                                                String lineOrIncrement = tabInc[0].trim();
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
                                                            System.err.printf("Line increment value for label '%s' found in file %s line %d was already set to %d", labelName, fileName, lineData.sourceNumber, incrementStep);
                                                        }
                                                        lineOrIncrement = lineOrIncrement.substring(1);
                                                        try {
                                                            incrementStep = Integer.parseInt(lineOrIncrement);
                                                            hasSetIncrement = true;
                                                        } catch (NumberFormatException nfe) {
                                                            System.err.printf("Line increment value %s is not an integer", lineOrIncrement);
                                                        }
                                                    }
                                                    else
                                                    {
                                                        // Line number
                                                        if (hasSetNumber)
                                                        {
                                                            System.err.printf("Line number value for label '%s' found in file %s line %d was already set to %d", labelName, fileName, lineData.sourceNumber, lastLineNumber);
                                                        }
                                                        try {
                                                            lastLineNumber = Integer.parseInt(lineOrIncrement);
                                                        } catch (NumberFormatException nfe) {
                                                            System.err.printf("Invalid line number value '%s' for label '%s' found in file %s line %d", lineOrIncrement, labelName, fileName, lineData.sourceNumber);
                                                        }

                                                        setLabel(labelName, lastLineNumber);
                                                        hasSetNumber = true;
                                                    }
                                                }
                                            }

                                            if (!hasSetNumber)
                                            {
                                                setLabel(labelName, lastLineNumber + incrementStep);
                                            }
                                            shouldSkip = true;
                                        }
                                    }
                                }
                                else
                                {
                                    System.err.printf("Missing line number in file %s line %d", fileName, lineData.sourceNumber);
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
                                lineData.trimmedLine = ligne.strip();
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

        fileName = sourceFile;

        {
            //
            // Second pass: Solve the labels
            //
            int previousLineNumber = -1;

            for(LineData lineData : getSortedLines())
            {
                String currentLine = lineData.trimmedLine;
                currentLineNumber = lineData.sourceNumber;

                if (lineData.basicNumber < previousLineNumber)
                {
                    System.err.printf("BASIC line number %d in file %s line number line %d is smaller than the previous line %d", lineData.basicNumber, fileName, currentLineNumber, previousLineNumber);
                }
                previousLineNumber = lineData.basicNumber;

                if (!currentLine.isEmpty())
                {
                    String ligne = currentLine;
                    if (ligne.charAt(0) == '#')
                    {
                        // Preprocessor directive
                        if (ligne.startsWith("#file"))
                        {
                            //"#file font.BAS""
                            // Very approximative "get the name of the file and reset the line counter" code.
                            // Will clean up that when I will have some more time.
                            ligne = ligne.substring(5);
                            fileName = ligne;
                            currentLineNumber = 0;
                        }
                        else
                        {
                            System.err.printf("%s\r\nUnknown preprocessor directive in file %s line number line %d", ligne, fileName, lineData.sourceNumber);
                        }
                    }
                    else
                    {
                        // Standard line
                        stringBuffer.append((char)0);
                        stringBuffer.append((char)0);

                        stringBuffer.append((char)(lineData.basicNumber & 0xFF));
                        stringBuffer.append((char)(lineData.basicNumber >> 8));

                        boolean color          = useColor;
                        boolean isComment      = false;
                        boolean isQuotedString = false;
                        boolean isData         = false;

                        while (lineData.getCurrentChar() == ' ') lineData.skipChar();

                        while (lineData.pos < ligne.length())
                        {
                            char car = lineData.getCurrentChar();
                            char car2 = lineData.getNextChar();

                            if (isComment)
                            {
                                char value = lineData.getCurrentChar();
                                lineData.skipChar();
                                if (!optimize)
                                {
                                    if (color)
                                    {
                                        color = false;
                                        stringBuffer.append((char)27);	// ESCAPE
                                        stringBuffer.append('B');	// GREEN labels
                                    }
                                    stringBuffer.append(value);
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
                                        stringBuffer.append(car2-96);
                                        lineData.skipNChars(2);
                                    }
                                    else
                                    if ((car2 >= '@') && (car2 <= 'Z'))
                                    {
                                        stringBuffer.append((char)27);      // ESCAPE
                                        stringBuffer.append(car2);    // Actual control code
                                        lineData.skipNChars(2);
                                    }
                                    else
                                    {
                                        System.err.printf("The sequence '~%c' in file %s line number line %d is not a valid escape sequence ", car2, fileName, currentLineNumber);
                                    }

                                }
                                else
                                {
                                    stringBuffer.append(lineData.getCurrentChar());
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
                                    StringBuffer tempoStringBuffer = new StringBuffer();
                                    processPossibleLineNumberLabelOrDefine(tempoStringBuffer, lineData, false, optimize);
                                    processOptionalWhiteSpace(stringBuffer, lineData, optimize);
                                    if (tempoStringBuffer.isEmpty())
                                    {
                                        continue;
                                    } else {
                                        stringBuffer.append(stringBuffer.toString());
                                    }
                                }
                                stringBuffer.append(lineData.getCurrentChar());
                                lineData.skipChar();
                            }
                            else
                            {
                                processOptionalWhiteSpace(stringBuffer, lineData, optimize);

                                int keyw = searchKeyword(lineData);
                                if (keyw == Token_REM.ordinal() || (lineData.getCurrentChar() == '\''))
                                {
                                    // REM
                                    isComment = true;
                                    if (optimize)
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
                                    stringBuffer.append(lineData.basicNumber);
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
                                    stringBuffer.append(car);
                                    lineData.skipChar();
                                    // Open parenthesis
                                    processPossibleLineNumberLabelOrDefine(stringBuffer, lineData, false, optimize);
                                    continue;
                                }
                                else
                                if (car == ',')
                                {
                                    stringBuffer.append(car);
                                    lineData.skipChar();
                                    // comma
                                    processPossibleLineNumberLabelOrDefine(stringBuffer, lineData, false, optimize);
                                    continue;
                                }

                                if (keyw >= 0)
                                {
                                    stringBuffer.append((char)keyw | 128);
                                    lineData.skipNChars(keywords[keyw].length());
                                    processOptionalWhiteSpace(stringBuffer, lineData, optimize);

                                    //
                                    // Note: This bunch of tests should be replaced by actual flags associated to keywords to define their behavior:
                                    // - Can be followed by a line number
                                    // - Can be the complementary part of an expression (and thus should not be part of a symbol)
                                    // - ...
                                    //
                                    if (useExtendedBasic &&
                                            ((keyw == Token_GOTO.ordinal())
                                                    || (keyw == Token_GOSUB.ordinal())
                                                    || (keyw == Token_RESTORE.ordinal())
                                                    || (keyw == Token_CALL.ordinal())
                                                    || (keyw == Token_SymbolEqual.ordinal())
                                                    || (keyw == Token_SymbolMinus.ordinal())
                                                    || (keyw == Token_SymbolPlus.ordinal())
                                                    || (keyw == Token_SymbolDivide.ordinal())
                                                    || (keyw == Token_SymbolPlus.ordinal())
                                                    || (keyw == Token_TO.ordinal())
                                                    || (keyw == Token_THEN.ordinal())
                                                    || (keyw == Token_ELSE.ordinal())))
                                    {
                                        if ((keyw == Token_THEN.ordinal()) || (keyw == Token_ELSE.ordinal()))
                                        {
                                            if (searchKeyword(lineData) >= 0)
                                            {
                                                // THEN and ELSE instructions can be followed directly by a line number... but they can also have an instruction like PRINT
                                                processOptionalWhiteSpace(stringBuffer, lineData, optimize);
                                                continue;
                                            }
                                        }
                                        // Should have one or more (comma separated) numbers, variables, or labels.
                                        boolean shouldValidateLineNumber = ! ( (keyw == Token_SymbolEqual.ordinal()) ||
                                                (keyw == Token_SymbolMinus.ordinal()) ||
                                                (keyw == Token_SymbolPlus.ordinal()) ||
                                                (keyw == Token_SymbolMultiply.ordinal()) ||
                                                (keyw == Token_SymbolDivide.ordinal()));
                                        processPossibleLineNumberLabelOrDefine(stringBuffer, lineData, shouldValidateLineNumber,optimize);
                                        processOptionalWhiteSpace(stringBuffer, lineData, optimize);
                                    }
                                }
                                else
                                {
                                    if (!processPossibleLineNumberLabelOrDefine(stringBuffer, lineData, false, optimize))
                                    {
                                        stringBuffer.append(lineData.getCurrentChar());
                                        lineData.skipChar();
                                    }
                                }
                            }
                        }

                        if (optimize)
                        {
                            // Remove any white space at the end of the line
                            // while (((bufPtr-1) > (lineStart+4)) && (bufPtr[-1] == ' '))
                            while(stringBuffer.length()>4 && stringBuffer.charAt(stringBuffer.length()-1)==' ')
                            {
                                stringBuffer.deleteCharAt(stringBuffer.length()-1);
                            }
                        }
                        if (stringBuffer.length() == 4)
                        {
                            // If the line is empty, we add a REM token...
                            stringBuffer.append((char)(Token_REM.ordinal() | 128));
                        }

                        stringBuffer.append((char)0);

                        adr = 0x501 + stringBuffer.length();

                        stringBuffer.setCharAt(0,(char)(adr & 0xFF));
                        stringBuffer.setCharAt(0,(char)(adr >> 8));
                    }
                }
            }
            stringBuffer.append((char)0);
            stringBuffer.append((char)0);
        }

        //following line modified by Wilfrid AVRILLON (Waskol) 06/20/2009
        //It should follow this rule of computation : End_Address=Start_Address+File_Size-1
        //Let's assume a 1 byte program, it starts at address #501 and ends at address #501 (Address=Address+1-1) !
        //It was a blocking issue for various utilities (tap2wav for instance)
        //end=0x501+i-1;	        //end=0x501+i;
        int i = stringBuffer.length();
        end = 0x501 + i;

        byte head[]={ 0x16,0x16,0x16,0x24,0,0,0,0,0,0,5,1,0,0 };

        if (autoRun) head[7] = (byte)0x80;	// Autorun for basic :)
        else		head[7] = 0;

        head[8] = (byte)(end >> 8);
        head[9] = (byte)(end & 0xFF);

        //
        // Save file
        //
        dataOutputStream.write(head, 1, 13);
        // write the name
        if (fileName.length() > 0)
        {
            Path p = Path.of(fileName);
            String name = p.getFileName().toString();
            if (name.indexOf(".") > 0) {
                name = name.substring(0, name.lastIndexOf("."));
            }
            dataOutputStream.write(name.getBytes());
        }
        dataOutputStream.write(0);
        dataOutputStream.write(stringBuffer.toString().getBytes());
        // oricutron bug work around
        //fwrite("\x00", 1, 1, out);
        dataOutputStream.close();
    }

    public static void main(String[] args) throws IOException {
        Bas2Tap bas2Tap = new Bas2Tap();
        bas2Tap.bas2Tap("src/main/resources/intro.bas", "src/main/resources/intro2.tap",true,true,false);
    }

}