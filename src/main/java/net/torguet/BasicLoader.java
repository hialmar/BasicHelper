package net.torguet;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import static net.torguet.BasicProgram.keywords;
import static net.torguet.BasicProgram.searchKeyword;

public class BasicLoader {
    private final BufferedReader bufferedReader;
    private final BasicProgram basicProgram;
    private int currentLineNumber;
    private String fileName;

    public BasicLoader(String fileName) throws Exception {
        currentLineNumber = 0;
        this.fileName = fileName;
        bufferedReader = new BufferedReader(new FileReader(fileName));
        basicProgram = new BasicProgram();
    }

    public void readProgram() throws Exception {
        String line = "";
        while (line != null) {
            line = bufferedReader.readLine();
            if (line != null)
                basicProgram.addLine(line);
        }
        bufferedReader.close();
    }

    public BasicProgram getBasicProgram() {
        return basicProgram;
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
            fileOutputStream.print(" "+lineNumber+" ");
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

    private char processOptionalWhiteSpace(StringBuffer bufPtr, String ligne, boolean optimize)
    {
        char car = 1;
        int i = 0;
        while (car != 0)
        {
            car = ligne.charAt(i);
            if (car == ' ')  // Space
            {
                if (!optimize)
                {
                    bufPtr.append(car);
                }
                i++;
            }
            else
            if (car == '\t') // Tab
            {
                if (!optimize)
                {
                    bufPtr.append(car);
                }
                i++;
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

    private String getPotentialSymbolName(String ligne)
    {
        String potentialLabelName = null;
        int i =0;
        char car = ligne.charAt(i);
        while ((isValidLabelName(car) || isValidLineNumber(car)) && (searchKeyword(ligne)<0))
        {
            potentialLabelName += car;
            i++;
            car = ligne.charAt(i);
            ligne = ligne.substring(i);
        }
        return potentialLabelName;
    }

    boolean processPossibleLineNumberLabelOrDefine(StringBuffer bufPtr, String ligne,
                                                   boolean shouldValidateLineNumber, boolean optimize)
    {
        // Should have one or more (comma separated) numbers, variables, or labels.
        char car = processOptionalWhiteSpace(bufPtr, ligne, optimize);
        if (isValidLineNumber(car))
        {
            // Line  Number
            int lineNumber = 0;
            int i = 0;
            car = ligne.charAt(i);
            while (isValidLineNumber(car))
            {
                lineNumber = (lineNumber * 10) + (car - '0');
                bufPtr.append(car);
                i++;
                car = ligne.charAt(i);
            }
            if (shouldValidateLineNumber && !basicProgram.isValidLineNumber(lineNumber))
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

                BasicProgram.LabelInfos infos = basicProgram.findLabel(potentialLabelName);
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
                    String findIt = basicProgram.findDefine(potentialLabelName);
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

    class LineData {
        LineData() {
            trimmedLine = "";
            sourceNumber = -1;
            basicNumber = -1;
        }

        String trimmedLine;
        int sourceNumber;
        int basicNumber;
    }


    private void bas2Tap(String sourceFile, String destFile,
                         boolean autoRun, boolean useColor, boolean optimize) throws IOException {
        StringBuffer buf;
        int end, adr;

        boolean useExtendedBasic = false;


        // Mike: Need to improve the parsing of this with a global function to split
        // a text file in separate lines.
        BufferedReader fileReader = new BufferedReader(new FileReader(sourceFile));
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
            LineData lineData;
            lineData.sourceNumber = 0;

            for(String line : textData)
            {
                lineData.sourceNumber++;
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
                                ligne = ligne.substring(5);
                                fileName = ligne;
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
                                ligne = ligne.substring(7).strip();
                                String [] tab = ligne.split("[ \t]");
                                if (tab.length < 2) {
                                    System.err.println("Define missing value");
                                    return;
                                }
                                String defineName  = tab[0].strip();
                                String defineValue = tab[1].strip();

                                String potentialUsableName = getPotentialSymbolName(defineName);
                                if (!potentialUsableName.equals(defineName))
                                {
                                    int keyw = searchKeyword(defineName);
                                    if (keyw >= 0)
                                    {
                                        System.err.printf("Define named '%s' in file %s line number line %d contains the name of a BASIC instruction '%s'",
                                                defineName, fileName, lineData.sourceNumber, BasicProgram.getKeywords()[keyw]);
                                        return;
                                    }
                                }

                                basicProgram.addDefine(defineName,defineValue);

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
                                    System.err.printf("#import directive in file %s line number line %d should be followed by a quoted path", m_CurrentFileName.c_str(), lineData.sourceNumber);
                                    return;
                                }
                                importPathName = importPathName.substring(startQuote + 1, endQuote - 1);  // Keep the part between the quotes

                                void* ptr_buffer_void;
                                size_t size_buffer_src;

                                //
                                // Load the symbol file (XA format)
                                //
                                if (!LoadFile(importPathName.c_str(), ptr_buffer_void, size_buffer_src))
                                {
                                    ShowError("Unable to load symbol file '%s'", importPathName.c_str());
                                }

                                unsigned char* ptr_buffer = (unsigned char*)ptr_buffer_void;

                                char* ptr_tok = strtok((char*)ptr_buffer, " \r\n");
                                while (ptr_tok)
                                {
                                    int symbolAddress = strtol(ptr_tok, 0, 16);    // Address
                                    ptr_tok = strtok(0, " \r\n");          // Name
                                    if (*ptr_tok == '_')
                                    {
                                        // We are only interested in symbols with external linkage
                                        ++ptr_tok;
                                        std::string defineName(ptr_tok);

                  const char* ptrDefineName = ptr_tok;
                                        std::string potentialUsableName = GetPotentialSymbolName(ptrDefineName);
                                        if (potentialUsableName != defineName)
                                        {
                                            int keyw = search_keyword(ptrDefineName);
                                            if (keyw >= 0)
                                            {
                                                ShowError("Define named '%s' in file %s contains the name of a BASIC instruction '%s'", defineName.c_str(), importPathName.c_str(), keywords[keyw]);
                                            }
                                        }
                                        m_Defines[defineName] = std::to_string(symbolAddress);
                                    }
                                    ptr_tok = strtok(0, " \r\n");
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
                                ShowError("%s\r\nUnknown preprocessor directive in file %s line number line %d", ligne, m_CurrentFileName.c_str(), lineData.sourceNumber);
                            }
                        }
                        else
                        {
                            // Standard line
                            int number = get_value(ligne, -1);
                            if (number<0)
                            {
                                char car = ligne[0];
                                if (car != 0)
                                {
                                    char car2 = ligne[1];
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
                                        std::string line(ligne);
                                        labelName = StringTrim(StringSplit(line, ": \t"));
                                        if (labelName.empty())
                                        {
                                            // Not a label, so maybe a line of basic without line number
                                            ShowError("Missing label information in file %s line %d", m_CurrentFileName.c_str(), lineData.sourceNumber);
                                            break;
                                        }
                                        else
                                        {
                                            // Definitely a label, or something unfortunately detected as a label because of the ":" at the end :p
                                            if (m_Labels.find(labelName) != m_Labels.end())
                                            {
                                                ShowError("Label '%s' found in file %s line %d is already defined", labelName.c_str(), m_CurrentFileName.c_str(), lineData.sourceNumber);
                                                break;
                                            }

                                            bool hasSetIncrement = false;
                                            bool hasSetNumber = false;

                                            while (!line.empty())
                                            {
                                                std::string lineOrIncrement = StringTrim(StringSplit(line, ": \t"));
                                                if (!lineOrIncrement.empty())
                                                {
                                                    char car  = lineOrIncrement[0];
                                                    char car2 = (lineOrIncrement.size()>=2)?lineOrIncrement[1]:0;
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
                                                            ShowError("Line increment value for label '%s' found in file %s line %d was already set to %d", labelName.c_str(), m_CurrentFileName.c_str(), lineData.sourceNumber, incrementStep);
                                                        }
                                                        lineOrIncrement = lineOrIncrement.substr(1);
                                                        incrementStep = std::stoi(lineOrIncrement);
                                                        hasSetIncrement = true;
                                                    }
                                                    else
                                                    {
                                                        // Line number
                                                        if (hasSetNumber)
                                                        {
                                                            ShowError("Line number value for label '%s' found in file %s line %d was already set to %d", labelName.c_str(), m_CurrentFileName.c_str(), lineData.sourceNumber, lastLineNumber);
                                                        }
                                                        char* endPtr = nullptr;
                          const char* startPtr = lineOrIncrement.c_str();
                                                        lastLineNumber = std::strtol(startPtr,&endPtr,10);
                                                        if (startPtr == endPtr)
                                                        {
                                                            ShowError("Invalid line number value '%s' for label '%s' found in file %s line %d", startPtr, labelName.c_str(), m_CurrentFileName.c_str(), lineData.sourceNumber);
                                                        }

                                                        m_Labels[labelName] = lastLineNumber;
                                                        hasSetNumber = true;
                                                    }
                                                }
                                            }

                                            if (!hasSetNumber)
                                            {
                                                m_Labels[labelName] = lastLineNumber + incrementStep;
                                            }
                                            shouldSkip = true;
                                        }
                                    }
                                }
                                else
                                {
                                    ShowError("Missing line number in file %s line %d", m_CurrentFileName.c_str(), lineData.sourceNumber);
                                    break;
                                }
                            }
                            else
                            {
                                // We have a valid line number, if we have a pending label, record it
                                if (!labelName.empty())
                                {
                                    m_Labels[labelName] = number;
                                    labelName.clear();
                                }
                                lineData.trimmedLine = StringTrim(ligne);
                            }
                            if (number >= 0)
                            {
                                lineData.basicNumber = number;
                                lastLineNumber = number;
                                m_ValidLineNumbers.insert(number);
                            }
                        }
                        if (!shouldSkip)
                        {
                            // No need to add labels as actual lines to parse
                            m_ActualLines.push_back(lineData);
                        }
                    }
                }
            }
        }

        unsigned char* bufPtr = buf;
        m_CurrentFileName = sourceFile;

        {
            //
            // Second pass: Solve the labels
            //
            int previousLineNumber = -1;

            std::vector<LineData>::const_iterator lineIt = m_ActualLines.begin();
            while (lineIt != m_ActualLines.end())
            {
      const LineData& lineData(*lineIt);
                std::string currentLine = lineData.trimmedLine;
                m_CurrentLineNumber = lineData.sourceNumber;

                if (lineData.basicNumber < previousLineNumber)
                {
                    ShowError("BASIC line number %d in file %s line number line %d is smaller than the previous line %d", lineData.basicNumber, m_CurrentFileName.c_str(), m_CurrentLineNumber, previousLineNumber);
                }
                previousLineNumber = lineData.basicNumber;

                if (!currentLine.empty())
                {
        const char* ligne = currentLine.c_str();
                    if (ligne[0] == '#')
                    {
                        // Preprocessor directive
                        if (memicmp(ligne, "#file", 5) == 0)
                        {
                            //"#file font.BAS""
                            // Very approximative "get the name of the file and reset the line counter" code.
                            // Will clean up that when I will have some more time.
                            ligne += 5;
                            m_CurrentFileName = ligne;
                            m_CurrentLineNumber = 0;
                        }
                        else
                        {
                            ShowError("%s\r\nUnknown preprocessor directive in file %s line number line %d", ligne, m_CurrentFileName.c_str(), lineData.sourceNumber);
                        }
                    }
                    else
                    {
                        // Standard line
                        unsigned char* lineStart = bufPtr;

          *bufPtr++ = 0;
          *bufPtr++ = 0;

          *bufPtr++ = lineData.basicNumber & 0xFF;
          *bufPtr++ = lineData.basicNumber >> 8;

                        bool color          = useColor;
                        bool isComment      = false;
                        bool isQuotedString = false;
                        bool isData         = false;


                        while (*ligne == ' ') ligne++;


                        while (*ligne)
                        {
                            unsigned char car = *ligne;
                            unsigned char car2 = *(ligne + 1);

                            if (isComment)
                            {
                                char value = *ligne++;
                                if (!optimize)
                                {
                                    if (color)
                                    {
                                        color = false;
                  *bufPtr++ = 27;	// ESCAPE
                  *bufPtr++ = 'B';	// GREEN labels
                                    }
                *bufPtr++ = value;
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
                  *bufPtr++ = car2-96;
                                        ligne+=2;
                                    }
                                    else
                                    if ((car2 >= '@') && (car2 <= 'Z'))
                                    {
                  *bufPtr++ = 27;      // ESCAPE
                  *bufPtr++ = car2;    // Actual control code
                                        ligne+=2;
                                    }
                                    else
                                    {
                                        ShowError("The sequence '~%c' in file %s line number line %d is not a valid escape sequence ", car2, m_CurrentFileName.c_str(), m_CurrentLineNumber);
                                    }

                                }
                                else
                                {
                *bufPtr++ = *ligne++;
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
                                    auto previousPtr = bufPtr;
                                    ProcessPossibleLineNumberLabelOrDefine(bufPtr, ligne, false, optimize);
                                    ProcessOptionalWhiteSpace(bufPtr, ligne, optimize);
                                    if (previousPtr != bufPtr)
                                    {
                                        continue;
                                    }
                                }
              *bufPtr++ = *ligne++;
                            }
                            else
                            {
                                ProcessOptionalWhiteSpace(bufPtr, ligne, optimize);

                                int keyw = search_keyword(ligne);
                                if (keyw == Token_REM || (*ligne == '\''))
                                {
                                    // REM
                                    isComment = true;
                                    if (optimize)
                                    {
                                        continue;
                                    }
                                }
              else
                                if (keyw == Token_DATA)
                                {
                                    // DATA
                                    isData = true;
                                }

                                car  = *ligne;
                                car2 = *(ligne+1);

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
                                    bufPtr += sprintf((char*)bufPtr, "%d", lineData.basicNumber);
                                    ++ligne;
                                    if (car == 0xC2)
                                    {
                                        // Need to skip two characters...
                                        ++ligne;
                                    }
                                    continue;
                                }
                                else
                                if (car == '(')
                                {
                *bufPtr++ = *ligne++;  // Open parenthesis
                                    ProcessPossibleLineNumberLabelOrDefine(bufPtr, ligne, false, optimize);
                                    continue;
                                }
                                else
                                if (car == ',')
                                {
                *bufPtr++ = *ligne++;  // comma
                                    ProcessPossibleLineNumberLabelOrDefine(bufPtr, ligne, false, optimize);
                                    continue;
                                }

                                if (keyw >= 0)
                                {
                *bufPtr++ = keyw | 128;
                                    ligne += strlen(keywords[keyw]);
                                    ProcessOptionalWhiteSpace(bufPtr, ligne, optimize);

                                    //
                                    // Note: This bunch of tests should be replaced by actual flags associated to keywords to define their behavior:
                                    // - Can be followed by a line number
                                    // - Can be the complementary part of an expression (and thus should not be part of a symbol)
                                    // - ...
                                    //
                                    if (useExtendedBasic &&
                                            ((keyw == Token_GOTO)
                                                    || (keyw == Token_GOSUB)
                                                    || (keyw == Token_RESTORE)
                                                    || (keyw == Token_CALL)
                                                    || (keyw == Token_SymbolEqual)
                                                    || (keyw == Token_SymbolMinus)
                                                    || (keyw == Token_SymbolPlus)
                                                    || (keyw == Token_SymbolDivide)
                                                    || (keyw == Token_SymbolPlus)
                                                    || (keyw == Token_TO)
                                                    || (keyw == Token_THEN)
                                                    || (keyw == Token_ELSE)))
                                    {
                                        if ((keyw == Token_THEN) || (keyw == Token_ELSE))
                                        {
                                            if (search_keyword(ligne) >= 0)
                                            {
                                                // THEN and ELSE instructions can be followed directly by a line number... but they can also have an instruction like PRINT
                                                ProcessOptionalWhiteSpace(bufPtr, ligne, optimize);
                                                continue;
                                            }
                                        }
                                        // Should have one or more (comma separated) numbers, variables, or labels.
                                        bool shouldValidateLineNumber = ! ( (keyw == Token_SymbolEqual) || (keyw == Token_SymbolMinus) || (keyw == Token_SymbolPlus) || (keyw == Token_SymbolMultiply) || (keyw == Token_SymbolDivide));
                                        ProcessPossibleLineNumberLabelOrDefine(bufPtr, ligne, shouldValidateLineNumber,optimize);
                                        ProcessOptionalWhiteSpace(bufPtr, ligne, optimize);
                                    }
                                }
                                else
                                {
                                    if (!ProcessPossibleLineNumberLabelOrDefine(bufPtr, ligne, false, optimize))
                                    {
                  *bufPtr++ = *ligne++;
                                    }
                                }
                            }
                        }

                        if (optimize)
                        {
                            // Remove any white space at the end of the line
                            while (((bufPtr-1) > (lineStart+4)) && (bufPtr[-1] == ' '))
                            {
                                --bufPtr;
                            }
                        }
                        if (bufPtr == lineStart + 4)
                        {
                            // If the line is empty, we add a REM token...
            *bufPtr++ = Token_REM | 128;
                        }

          *bufPtr++ = 0;

                        adr = 0x501 + bufPtr-buf;

          *lineStart++ = adr & 0xFF;
          *lineStart++ = adr >> 8;

                    }
                }
                ++lineIt;
            }
    *bufPtr++ = 0;
    *bufPtr++ = 0;
        }

        //following line modified by Wilfrid AVRILLON (Waskol) 06/20/2009
        //It should follow this rule of computation : End_Address=Start_Address+File_Size-1
        //Let's assume a 1 byte program, it starts at address #501 and ends at address #501 (Address=Address+1-1) !
        //It was a blocking issue for various utilities (tap2wav for instance)
        //end=0x501+i-1;	        //end=0x501+i;
        int i = bufPtr - buf;
        end = 0x501 + i;

        if (autoRun)	head[7] = 0x80;	// Autorun for basic :)
        else		head[7] = 0;

        head[8] = end >> 8;
        head[9] = end & 0xFF;

        //
        // Save file
        //
        FILE *out = fopen(destFile, "wb");
        if (out == NULL)
        {
            printf("Can't open file for writing\n");
            exit(1);
        }
        fwrite(head, 1, 13, out);
        // write the name
        if (m_CurrentFileName.length() > 0)
        {
            char *currentFileDup = strdup(m_CurrentFileName.c_str());
            char *fileName = currentFileDup;
            // only take the file name from the path
            // try to find '\\'
            char *lastsep = strrchr(fileName, '\\');
            if (lastsep != NULL)
            {
                // if there is something after the separator
                if ( lastsep[1] != 0)
                    fileName = lastsep + 1;
            }
            else
            {
                // try to find /
                lastsep = strrchr(fileName, '/');
                if (lastsep != NULL)
                {
                    // if there is something after the separator
                    if (lastsep[1] != 0)
                        fileName = lastsep + 1;
                }
            }
            // remove the extension if there is one
            char *lastdot = strrchr(fileName, '.');
            if (lastdot != NULL)
      *lastdot = 0;
            fwrite(fileName, 1, strlen(fileName), out);
            free(currentFileDup);
        }
        fwrite("\x00", 1, 1, out);
        fwrite(buf, 1, i + 1, out);
        // oricutron bug work around
        //fwrite("\x00", 1, 1, out);
        fclose(out);
    }




    public static void main(String[] args) throws Exception {
        BasicLoader.tap2Bas("src/main/resources/intro.tap", "src/main/resources/intro2.bas");
        BasicLoader basicLoader = new BasicLoader("src/main/resources/intro2.bas");
        basicLoader.readProgram();
        BasicProgram basicProgram = basicLoader.getBasicProgram();
        basicProgram.getSortedLines().forEach(System.out::println);
    }
}
