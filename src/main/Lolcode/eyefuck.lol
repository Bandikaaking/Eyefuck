

HAI 1.4
CAN HAS STDIO?

BTW my teacher knows lolcode (idk how)
I HAS A RESET ITZ "\033[0m"
I HAS A RED ITZ "\033[31m"
I HAS A GREEN ITZ "\033[32m"
I HAS A YELLOW ITZ "\033[33m"
I HAS A BLUE ITZ "\033[34m"
I HAS A CYAN ITZ "\033[36m"
I HAS A WHITE ITZ "\033[97m"

I HAS A EYF_V ITZ 1.2
I HAS A TAPE_SIZE ITZ 300000

HOW IZ I MAIN YR ARGS
    I HAS A ARG_COUNT ITZ BOTH SAEM ARGS AN WIN
    BOTH SAEM ARG_COUNT AN 0, O RLY?
        YA RLY
            VISIBLE RED "Usage:" RESET " eyefuck <command> [file.eyf]"
            GTFO
        OIC

    I HAS A MODE ITZ ARGS'Z FIRST

    BOTH SAEM MODE AN "run", O RLY?
        YA RLY
            BOTH SAEM ARG_COUNT AN 1, O RLY?
                YA RLY
                    VISIBLE RED "Please specify a file to run." RESET
                    GTFO
            OIC
            I HAS A FILE ITZ ARGS'Z NEXT
            I HAS A CODE ITZ ""
            I HAS A FILE_HANDLE ITZ I IZ OPEN YR FILE ANR "r" MKAY
            FILE_HANDLE, O RLY?
                YA RLY
                    I HAS A LINE
                    IM IN YR LOOP
                        LINE R I IZ READ YR FILE_HANDLE MKAY
                        BOTH SAEM LINE AN WIN, O RLY?
                            YA RLY, GTFO
                        OIC
                        CODE R SMOOSH CODE LINE "\n" MKAY
                    IM OUTTA YR LOOP
                    I IZ CLOSE YR FILE_HANDLE MKAY
                    I IZ RUN_INTERPRETER YR CODE MKAY
                NO WAI
                    VISIBLE "Error reading file"
            OIC

    MEBBE BOTH SAEM MODE AN "-i" OR BOTH SAEM MODE AN "--i" OR BOTH SAEM MODE AN "i"
        I IZ START_REPL MKAY

    MEBBE BOTH SAEM MODE AN "help" OR BOTH SAEM MODE AN "-help" OR BOTH SAEM MODE AN "-h" OR BOTH SAEM MODE AN "--h" OR BOTH SAEM MODE AN "--help"
        VISIBLE CYAN "Eyefuck HELP:" RESET
        VISIBLE YELLOW "  eyefuck run <file.eyf>" RESET "  -> " GREEN "execute the Eyefuck file" RESET
        VISIBLE YELLOW "  eyefuck -i" RESET "             -> " GREEN "interactive REPL mode" RESET
        VISIBLE YELLOW "  eyefuck about" RESET "          -> " GREEN "information about this interpreter" RESET

    MEBBE BOTH SAEM MODE AN "about"
        VISIBLE CYAN "Eyefuck DEV 2025" RESET
        VISIBLE GREEN "MIT license" RESET " see LICENSE for more information"
        VISIBLE "Please help me motive by giving the repo a star"
        VISIBLE BLUE "github:" RESET " github.com/bandikaaking"
        VISIBLE "crafted with " RED "<3" RESET " by " YELLOW "@Bandikaaking" RESET

    MEBBE BOTH SAEM MODE AN "version" OR BOTH SAEM MODE AN "--v" OR BOTH SAEM MODE AN "--version" OR BOTH SAEM MODE AN "-v" OR BOTH SAEM MODE AN "v" OR BOTH SAEM MODE AN "-version"
        VISIBLE "Current eyefuck version: " EYF_V

    MEBBE BOTH SAEM MODE AN "ov" OR BOTH SAEM MODE AN "-ov" OR BOTH SAEM MODE AN "--ov"
        VISIBLE "Other Eyefuck versions: "
        VISIBLE "0.10: Started / added 2 instructions"
        VISIBLE "0.11-0.43: Fixed many bugs, and edded 5 more instructions"
        VISIBLE "1.0: Added syntax highliting"
        VISIBLE "1.1: Fixed bugs"
        VISIBLE "added more eyefuck modes / rewrited README.md"

    NO WAI
        VISIBLE RED "Unknown mode:" RESET " " MODE
    OIC

IF U SAY SO

HOW IZ I START_REPL
    VISIBLE CYAN "Eyefuck DEV 2025 - REPL" RESET
    VISIBLE "Type commands below, empty line to execute, Ctrl+C to exit"
    
    I HAS A CODE_LINES ITZ A BUKKIT
    I HAS A LINE_COUNT ITZ 0

    IM IN YR LOOP
        VISIBLE "$ " !
        I HAS A LINE ITZ I IZ READ YR STDIN MKAY
        LINE R I IZ TRIM YR LINE MKAY
        
        BOTH SAEM LINE AN "", O RLY?
            YA RLY
                I HAS A FULL_CODE ITZ ""
                IM IN YR LOOP2 UPPIN YR I TIL BOTH SAEM I AN LINE_COUNT
                    FULL_CODE R SMOOSH FULL_CODE CODE_LINES'Z SRS I "\n" MKAY
                IM OUTTA YR LOOP2
                I IZ RUN_INTERPRETER YR FULL_CODE MKAY
                CODE_LINES R A BUKKIT
                LINE_COUNT R 0
            NO WAI
                CODE_LINES'Z SRS LINE_COUNT R LINE
                LINE_COUNT R SUM OF LINE_COUNT AN 1
        OIC
    IM OUTTA YR LOOP

IF U SAY SO

HOW IZ I RUN_INTERPRETER YR CODE
    I HAS A TAPE ITZ A BUKKIT
    IM IN YR INIT UPPIN YR I TIL BOTH SAEM I AN TAPE_SIZE
        TAPE'Z SRS I R 0
    IM OUTTA YR INIT

    I HAS A PTR ITZ 0
    I HAS A LINES ITZ I IZ SPLIT YR CODE BY "\n" MKAY
    I HAS A LOOP_STACK ITZ A BUKKIT
    I HAS A STACK_PTR ITZ 0
    I HAS A I ITZ 0

    IM IN YR MAIN_LOOP TIL BOTH SAEM I AN LINES'Z LENGTH
        I HAS A LINE ITZ LINES'Z SRS I
        LINE R I IZ TRIM YR LINE MKAY
        
        I HAS A COMMENT_POS ITZ I IZ FIND YR LINE IN "#" MKAY
        DIFFRINT COMMENT_POS AN -1, O RLY?
            YA RLY
                LINE R I IZ SUBSTR YR LINE FROM 0 TO COMMENT_POS MKAY
                LINE R I IZ TRIM YR LINE MKAY
        OIC

        BOTH SAEM LINE AN "", O RLY?
            YA RLY, I IZ UPPIN YR I, GTFO
        OIC

        BOTH SAEM LINE AN "^", O RLY?
            YA RLY
                TAPE'Z SRS PTR R SUM OF TAPE'Z SRS PTR AN 1
        OIC

        BOTH SAEM LINE AN "v", O RLY?
            YA RLY
                TAPE'Z SRS PTR R DIFF OF TAPE'Z SRS PTR AN 1
        OIC

        BOTH SAEM LINE AN ">", O RLY?
            YA RLY
                PTR R MOD OF SUM OF PTR AN 1 AN TAPE_SIZE
        OIC

        BOTH SAEM LINE AN "<", O RLY?
            YA RLY
                PTR R BOTH SAEM PTR AN 0, O RLY?
                    YA RLY, TAPE_SIZE - 1
                    NO WAI, DIFF OF PTR AN 1
                OIC
        OIC

        I HAS A PREFIX3 ITZ I IZ SUBSTR YR LINE FROM 0 TO 3 MKAY
        BOTH SAEM PREFIX3 AN "bin", O RLY?
            YA RLY
                I HAS A BIN_STR ITZ I IZ SUBSTR YR LINE FROM 3 TO LENGTH OF LINE MKAY
                BIN_STR R I IZ TRIM YR BIN_STR MKAY
                I HAS A VAL ITZ 0
                IM IN YR BIN_CONV UPPIN YR J TIL BOTH SAEM J AN LENGTH OF BIN_STR
                    I HAS A CHAR ITZ I IZ SUBSTR YR BIN_STR FROM J TO 1 MKAY
                    VAL R PRODUKT OF VAL AN 2
                    BOTH SAEM CHAR AN "1", O RLY?
                        YA RLY, VAL R SUM OF VAL AN 1
                    OIC
                IM OUTTA YR BIN_CONV
                TAPE'Z SRS PTR R VAL
        OIC

        BOTH SAEM PREFIX3 AN "col", O RLY?
            YA RLY
                I HAS A START ITZ I IZ FIND YR LINE IN "[" MKAY
                I HAS A END ITZ I IZ FIND YR LINE IN "]" MKAY
                DIFFRINT START AN -1 AND DIFFRINT END AN -1 AND BOTH SAEM END BIGR THAN SUM OF START AN 1, O RLY?
                    YA RLY
                        I HAS A HEX ITZ I IZ SUBSTR YR LINE FROM SUM OF START AN 1 TO DIFF OF END AN SUM OF START AN 1) MKAY
                        I HAS A COLOR_INT ITZ 0
                        IM IN YR HEX_CONV UPPIN YR J TIL BOTH SAEM J AN LENGTH OF HEX
                            I HAS A CHAR ITZ I IZ SUBSTR YR HEX FROM J TO 1 MKAY
                            COLOR_INT R PRODUKT OF COLOR_INT AN 16
                            I HAS A DIGIT ITZ 0
                            I IZ IS_DIGIT YR CHAR, O RLY?
                                YA RLY, DIGIT R DIFF OF I IZ ORD YR CHAR MKAY AN 48
                                NO WAI, DIGIT R SUM OF DIFF OF I IZ ORD YR CHAR MKAY AN 55 AN 32
                            OIC
                            COLOR_INT R SUM OF COLOR_INT AN DIGIT
                        IM OUTTA YR HEX_CONV
                        I HAS A R ITZ QUOSHUNT OF COLOR_INT AN 65536
                        I HAS A G ITZ MOD OF QUOSHUNT OF COLOR_INT AN 256 AN 256
                        I HAS A B ITZ MOD OF COLOR_INT AN 256
                        VISIBLE SMOOSH "\033[38;2;" R ";" G ";" B "m" MKAY !
        OIC

        I HAS A PREFIX5 ITZ I IZ SUBSTR YR LINE FROM 0 TO 5 MKAY
        BOTH SAEM PREFIX5 AN "load[", O RLY?
            YA RLY
                I HAS A START ITZ I IZ FIND YR LINE IN "[" MKAY
                I HAS A END ITZ I IZ FIND YR LINE IN "]" MKAY
                DIFFRINT START AN -1 AND DIFFRINT END AN -1 AND BOTH SAEM END BIGR THAN SUM OF START AN 1, O RLY?
                    YA RLY
                        I HAS A FILENAME ITZ I IZ SUBSTR YR LINE FROM SUM OF START AN 1 TO DIFF OF END AN SUM OF START AN 1) MKAY
                        I HAS A FILE_EXISTS ITZ WIN
                        TAPE'Z SRS PTR R 0
        OIC

        BOTH SAEM LINE AN ",", O RLY?
            YA RLY
                I HAS A INPUT ITZ I IZ READ YR STDIN MKAY
                TAPE'Z SRS PTR R I IZ ORD YR INPUT MKAY
        OIC

        BOTH SAEM LINE AN ".", O RLY?
            YA RLY
                VISIBLE I IZ CHR YR TAPE'Z SRS PTR MKAY !
        OIC

        BOTH SAEM LINE AN "loop[", O RLY?
            YA RLY
                LOOP_STACK'Z SRS STACK_PTR R I
                STACK_PTR R SUM OF STACK_PTR AN 1
        OIC

        BOTH SAEM LINE AN "]", O RLY?
            YA RLY
                BOTH SAEM TAPE'Z SRS PTR AN 0, O RLY?
                    YA RLY
                        STACK_PTR R DIFF OF STACK_PTR AN 1
                    NO WAI
                        I R LOOP_STACK'Z SRS DIFF OF STACK_PTR AN 1
                OIC
        OIC

        NO WAI
            VISIBLE RED "error caught while parsing"
            VISIBLE RED "at line: " LINE
            GTFO
        OIC

        I R SUM OF I AN 1
    IM OUTTA YR MAIN_LOOP

    VISIBLE ""
IF U SAY SO

HOW IZ I TRIM YR STR
    I HAS A RESULT ITZ STR
    I HAS A START ITZ 0
    I HAS A END ITZ LENGTH OF STR
    
    IM IN YR FIND_START UPPIN YR I TIL BOTH SAEM I AN LENGTH OF STR
        I HAS A CHAR ITZ I IZ SUBSTR YR STR FROM I TO 1 MKAY
        BOTH SAEM CHAR AN " " OR BOTH SAEM CHAR AN "\t" OR BOTH SAEM CHAR AN "\r", O RLY?
            YA RLY, START R SUM OF START AN 1
            NO WAI, GTFO
        OIC
    IM OUTTA YR FIND_START
    
    IM IN YR FIND_END UPPIN YR I FROM DIFF OF LENGTH OF STR AN 1 TO 0
        I HAS A CHAR ITZ I IZ SUBSTR YR STR FROM I TO 1 MKAY
        BOTH SAEM CHAR AN " " OR BOTH SAEM CHAR AN "\t" OR BOTH SAEM CHAR AN "\r", O RLY?
            YA RLY, END R I
            NO WAI, GTFO
        OIC
    IM OUTTA YR FIND_END
    
    RESULT R I IZ SUBSTR YR STR FROM START TO DIFF OF END AN START MKAY
    FOUND YR RESULT
IF U SAY SO

I IZ MAIN YR ARGS MKAY
KTHXBYE






