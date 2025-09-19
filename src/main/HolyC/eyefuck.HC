/* experimental, only works in TempleOS, and i am NOT that good in holyC so my good friend Tom writes it (i would link his github profile if he would have one..) */

//hello i am  Tom and i know HolyC really goooooooooood, but! holyC does not support ANSI colors....
//sry Andrew
 
#include "HCLib.h"

// HolyC doesn't have ANSI colors in the same way, but we can use TempleOS colors, AND... well..... i am only learing holyc for 2 years...
#define RESET "\c0"
#define RED "\c1"
#define GREEN "\c2"
#define YELLOW "\c3"
#define BLUE "\c4"
#define CYAN "\c6"
#define WHITE "\c7"

F64 EYF_V = 1.2;
U64 TAPE_SIZE = 300000;

// ---------------------------
// Main function
// ---------------------------
I64 Main(I64 argc, char **argv)
{
    if (argc < 2)
    {
        Print("%sUsage:%s eyefuck <command> [file.eyf]\n", RED, RESET);
        return 1;
    }

    char *mode = argv[1];

    if (StrCmp(mode, "run") == 0)
    {
        if (argc < 3)
        {
            Print("%sPlease specify a file to run.%s\n", RED, RESET);
            return 1;
        }
        char *file = argv[2];
        U8 *code = FileRead(file);
        if (code == NULL)
        {
            Print("Error reading file\n");
            return 1;
        }
        RunInterpreter(code);
        Free(code);
    }
    else if (StrCmp(mode, "-i") == 0 || StrCmp(mode, "--i") == 0 || StrCmp(mode, "i") == 0)
    {
        StartREPL();
    }
    else if (StrCmp(mode, "help") == 0 || StrCmp(mode, "-help") == 0 || 
             StrCmp(mode, "-h") == 0 || StrCmp(mode, "--h") == 0 || StrCmp(mode, "--help") == 0)
    {
        Print("%sEyefuck HELP:%s\n", CYAN, RESET);
        Print("%s  eyefuck run <file.eyf>%s  -> %sexecute the Eyefuck file%s\n", YELLOW, RESET, GREEN, RESET);
        Print("%s  eyefuck -i%s             -> %sinteractive REPL mode%s\n", YELLOW, RESET, GREEN, RESET);
        Print("%s  eyefuck about%s          -> %sinformation about this interpreter%s\n", YELLOW, RESET, GREEN, RESET);
    }
    else if (StrCmp(mode, "about") == 0)
    {
        Print("%sEyefuck DEV 2025%s\n", CYAN, RESET);
        Print("%sMIT license%s see LICENSE for more information\n", GREEN, RESET);
        Print("Please help me motive by giving the repo a star\n");
        Print("%sgithub:%s github.com/bandikaaking\n", BLUE, RESET);
        Print("crafted with %s<3%s by %s@Bandikaaking%s\n", RED, RESET, YELLOW, RESET);
    }
    else if (StrCmp(mode, "version") == 0 || StrCmp(mode, "--v") == 0 || 
             StrCmp(mode, "--version") == 0 || StrCmp(mode, "-v") == 0 || 
             StrCmp(mode, "v") == 0 || StrCmp(mode, "-version") == 0)
    {
        Print("Current eyefuck version: %f\n", EYF_V);
    }
    else if (StrCmp(mode, "ov") == 0 || StrCmp(mode, "-ov") == 0 || StrCmp(mode, "--ov") == 0)
    {
        Print("Other Eyefuck versions: \n");
        Print("0.10: Started / added 2 instructions\n");
        Print("0.11-0.43: Fixed many bugs, and edded 5 more instructions\n");
        Print("1.0: Added syntax highliting\n");
        Print("1.1: Fixed bugs\n");
        Print("added more eyefuck modes / rewrited README.md\n");
    }
    else
    {
        Print("%sUnknown mode:%s %s\n", RED, RESET, mode);
        return 1;
    }

    return 0;
}

// ---------------------------
// Interactive REPL
// ---------------------------
U0 StartREPL()
{
    Print("%sEyefuck DEV 2025 - REPL%s\n", CYAN, RESET);
    Print("Type commands below, empty line to execute, Ctrl+C to exit\n");
    
    U8 *code_lines = MAlloc(4096);
    code_lines[0] = 0;
    U64 total_size = 4096;
    U64 current_len = 0;
    
    while (TRUE)
    {
        Print("$ ");
        U8 line[256];
        if (!Gets(line, sizeof(line)))
            break;
        
        if (StrLen(line) == 0)
        {
            RunInterpreter(code_lines);
            code_lines[0] = 0;
            current_len = 0;
            continue;
        }
        
        // Resize if needed
        U64 line_len = StrLen(line);
        if (current_len + line_len + 2 > total_size)
        {
            total_size *= 2;
            code_lines = ReAlloc(code_lines, total_size);
        }
        
        StrCat(code_lines, line);
        StrCat(code_lines, "\n");
        current_len += line_len + 1;
    }
    
    Free(code_lines);
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
U0 RunInterpreter(U8 *code)
{
    U8 *tape = MAlloc(TAPE_SIZE);
    SetMem(tape, 0, TAPE_SIZE);
    U64 ptr = 0;
    
    U8 **lines;
    U64 line_count = 0;
    U8 *code_copy = StrDup(code);
    
    // Split into lines
    U8 *line = StrTok(code_copy, "\n");
    while (line)
    {
        lines = ReAlloc(lines, (line_count + 1) * sizeof(U8 *));
        lines[line_count++] = line;
        line = StrTok(NULL, "\n");
    }
    
    U64 *loop_stack = NULL;
    U64 loop_stack_ptr = 0;
    
    for (U64 i = 0; i < line_count; i++)
    {
        U8 current_line[256];
        StrCpy(current_line, lines[i]);
        
        // Remove comments after #
        U8 *comment_pos = StrChr(current_line, '#');
        if (comment_pos)
            *comment_pos = 0;
        
        // Trim whitespace
        U8 *trimmed = current_line;
        while (*trimmed == ' ' || *trimmed == '\t') trimmed++;
        U8 *end = trimmed + StrLen(trimmed) - 1;
        while (end > trimmed && (*end == ' ' || *end == '\t' || *end == '\r')) end--;
        *(end + 1) = 0;
        
        if (StrLen(trimmed) == 0)
            continue;

        if (StrCmp(trimmed, "^") == 0)
        {
            // increment cell
            tape[ptr]++;
        }
        else if (StrCmp(trimmed, "v") == 0)
        {
            // decrement cell
            tape[ptr]--;
        }
        else if (StrCmp(trimmed, ">") == 0)
        {
            // move pointer right
            ptr = (ptr + 1) % TAPE_SIZE;
        }
        else if (StrCmp(trimmed, "<") == 0)
        {
            // move pointer left
            ptr = (ptr == 0) ? TAPE_SIZE - 1 : ptr - 1;
        }
        else if (StrStartsWith(trimmed, "bin"))
        {
            // set cell from binary
            U8 *bin_str = trimmed + 3;
            while (*bin_str == ' ' || *bin_str == '\t') bin_str++;
            tape[ptr] = (U8)StrToI64(bin_str, NULL, 2);
        }
        else if (StrStartsWith(trimmed, "col"))
        {
            // set text color from HEX - HolyC doesn't support ANSI colors, so we skip
            // This would be a no-op in TempleOS
        }
        else if (StrStartsWith(trimmed, "load["))
        {
            // load file
            U8 *start = StrChr(trimmed, '[');
            U8 *end = StrChr(trimmed, ']');
            if (start && end && end > start + 1)
            {
                *end = 0;
                U8 *filename = start + 1;
                if (FileExists(filename))
                {
                    tape[ptr] = 0;
                }
            }
        }
        else if (StrCmp(trimmed, ",") == 0)
        {
            // read single byte input
            tape[ptr] = GetChar();
        }
        else if (StrCmp(trimmed, ".") == 0)
        {
            // print cell as char
            PutChar(tape[ptr]);
        }
        else if (StrCmp(trimmed, "loop[") == 0)
        {
            // start loop
            loop_stack = ReAlloc(loop_stack, (loop_stack_ptr + 1) * sizeof(U64));
            loop_stack[loop_stack_ptr++] = i;
        }
        else if (StrCmp(trimmed, "]") == 0)
        {
            // end loop
            if (tape[ptr] != 0)
            {
                if (loop_stack_ptr > 0)
                {
                    i = loop_stack[loop_stack_ptr - 1];
                }
            }
            else
            {
                if (loop_stack_ptr > 0)
                {
                    loop_stack_ptr--;
                }
            }
        }
        else
        {
            Print("%serror caught while parsing\n", RED);
            Print("%sat line: %s\n", RED, trimmed);
            break;
        }
    }
    
    Print("\n");
    Free(tape);
    Free(code_copy);
    Free(lines);
    Free(loop_stack);
}
