// c version,
/* i did this... with only 2 weeks?!!?? wow i am lazy as HELL, i wroted the eyefuck.lua / eyefuck.rb  under 2 hours. Sooo i guess i am lazy*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// ANSI colors
#define RESET "\033[0m"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define BLUE "\033[34m"
#define CYAN "\033[36m"
#define WHITE "\033[97m"

#define EYF_V 1.2
#define TAPE_SIZE 300000

// Function prototypes
void run_interpreter(const char *code);
void start_repl();

// ---------------------------
// Main function
// ---------------------------
int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf(RED "Usage:" RESET " eyefuck <command> [file.eyf]\n");
        return 1;
    }

    char *mode = argv[1];

    if (strcmp(mode, "run") == 0) {
        if (argc < 3) {
            printf(RED "Please specify a file to run." RESET "\n");
            return 1;
        }
        char *file = argv[2];
        FILE *fp = fopen(file, "r");
        if (!fp) {
            perror("Error opening file");
            return 1;
        }
        fseek(fp, 0, SEEK_END);
        long file_size = ftell(fp);
        fseek(fp, 0, SEEK_SET);
        char *code = malloc(file_size + 1);
        fread(code, 1, file_size, fp);
        code[file_size] = '\0';
        fclose(fp);
        run_interpreter(code);
        free(code);
    }
    else if (strcmp(mode, "-i") == 0 || strcmp(mode, "--i") == 0 || strcmp(mode, "i") == 0) {
        start_repl();
    }
    else if (strcmp(mode, "help") == 0 || strcmp(mode, "-help") == 0 || 
             strcmp(mode, "-h") == 0 || strcmp(mode, "--h") == 0 || strcmp(mode, "--help") == 0) {
        printf(CYAN "Eyefuck HELP:" RESET "\n");
        printf(YELLOW "  eyefuck run <file.eyf>" RESET "  -> " GREEN "execute the Eyefuck file" RESET "\n");
        printf(YELLOW "  eyefuck -i" RESET "             -> " GREEN "interactive REPL mode" RESET "\n");
        printf(YELLOW "  eyefuck about" RESET "          -> " GREEN "information about this interpreter" RESET "\n");
    }
    else if (strcmp(mode, "about") == 0) {
        printf(CYAN "Eyefuck DEV 2025" RESET "\n");
        printf(GREEN "MIT license" RESET " see LICENSE for more information\n");
        printf("Please help me motive by giving the repo a star\n");
        printf(BLUE "github:" RESET " github.com/bandikaaking\n");
        printf("crafted with " RED "<3" RESET " by " YELLOW "@Bandikaaking" RESET "\n");
    }
    else if (strcmp(mode, "version") == 0 || strcmp(mode, "--v") == 0 || 
             strcmp(mode, "--version") == 0 || strcmp(mode, "-v") == 0 || 
             strcmp(mode, "v") == 0 || strcmp(mode, "-version") == 0) {
        printf("Current eyefuck version: %.1f\n", EYF_V);
    }
    else if (strcmp(mode, "ov") == 0 || strcmp(mode, "-ov") == 0 || strcmp(mode, "--ov") == 0) {
        printf("Other Eyefuck versions: \n");
        printf("0.10: Started / added 2 instructions\n");
        printf("0.11-0.43: Fixed many bugs, and edded 5 more instructions\n");
        printf("1.0: Added syntax highliting\n");
        printf("1.1: Fixed bugs\n");
        printf("added more eyefuck modes / rewrited README.md\n");
    }
    else {
        printf(RED "Unknown mode:" RESET " %s\n", mode);
        return 1;
    }

    return 0;
}

// ---------------------------
// Interactive REPL
// ---------------------------
void start_repl() {
    printf(CYAN "Eyefuck DEV 2025 - REPL" RESET "\n");
    printf("Type commands below, empty line to execute, Ctrl+C to exit\n");
    
    char *code_lines = malloc(4096);
    code_lines[0] = '\0';
    size_t total_size = 4096;
    size_t current_len = 0;
    
    while (1) {
        printf("$ ");
        char line[256];
        if (!fgets(line, sizeof(line), stdin)) {
            break;
        }
        
        // Remove newline
        line[strcspn(line, "\n")] = '\0';
        
        if (strlen(line) == 0) {
            run_interpreter(code_lines);
            code_lines[0] = '\0';
            current_len = 0;
            continue;
        }
        
        // Resize if needed
        size_t line_len = strlen(line);
        if (current_len + line_len + 2 > total_size) {
            total_size *= 2;
            code_lines = realloc(code_lines, total_size);
        }
        
        strcat(code_lines, line);
        strcat(code_lines, "\n");
        current_len += line_len + 1;
    }
    
    free(code_lines);
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
void run_interpreter(const char *code) {
    unsigned char *tape = calloc(TAPE_SIZE, sizeof(unsigned char));
    int ptr = 0;
    
    char *code_copy = strdup(code);
    char *lines[10000];
    int line_count = 0;
    
    // Split into lines
    char *line = strtok(code_copy, "\n");
    while (line && line_count < 10000) {
        lines[line_count++] = line;
        line = strtok(NULL, "\n");
    }
    
    int loop_stack[1000];
    int loop_stack_ptr = 0;
    
    for (int i = 0; i < line_count; i++) {
        char current_line[256];
        strncpy(current_line, lines[i], sizeof(current_line));
        current_line[sizeof(current_line) - 1] = '\0';
        
        // Remove comments after #
        char *comment_pos = strchr(current_line, '#');
        if (comment_pos) {
            *comment_pos = '\0';
        }
        
        // Trim whitespace
        char *trimmed = current_line;
        while (isspace(*trimmed)) trimmed++;
        char *end = trimmed + strlen(trimmed) - 1;
        while (end > trimmed && isspace(*end)) end--;
        *(end + 1) = '\0';
        
        if (strlen(trimmed) == 0) {
            continue;
        }

        if (strcmp(trimmed, "^") == 0) {
            // increment cell
            tape[ptr]++;
        }
        else if (strcmp(trimmed, "v") == 0) {
            // decrement cell
            tape[ptr]--;
        }
        else if (strcmp(trimmed, ">") == 0) {
            // move pointer right
            ptr = (ptr + 1) % TAPE_SIZE;
        }
        else if (strcmp(trimmed, "<") == 0) {
            // move pointer left
            ptr = (ptr == 0) ? TAPE_SIZE - 1 : ptr - 1;
        }
        else if (strncmp(trimmed, "bin", 3) == 0) {
            // set cell from binary
            char *bin_str = trimmed + 3;
            while (isspace(*bin_str)) bin_str++;
            tape[ptr] = (unsigned char)strtol(bin_str, NULL, 2);
        }
        else if (strncmp(trimmed, "col", 3) == 0) {
            // set text color from HEX
            char *start = strchr(trimmed, '[');
            char *end = strchr(trimmed, ']');
            if (start && end && end > start + 1) {
                *end = '\0';
                long color_int = strtol(start + 1, NULL, 16);
                int r = (color_int >> 16) & 0xFF;
                int g = (color_int >> 8) & 0xFF;
                int b = color_int & 0xFF;
                printf("\033[38;2;%d;%d;%dm", r, g, b);
            }
        }
        else if (strncmp(trimmed, "load[", 5) == 0) {
            // load file
            char *start = strchr(trimmed, '[');
            char *end = strchr(trimmed, ']');
            if (start && end && end > start + 1) {
                *end = '\0';
                FILE *fp = fopen(start + 1, "r");
                if (fp) {
                    fclose(fp);
                    tape[ptr] = 0;
                }
            }
        }
        else if (strcmp(trimmed, ",") == 0) {
            // read single byte input
            tape[ptr] = getchar();
        }
        else if (strcmp(trimmed, ".") == 0) {
            // print cell as char
            putchar(tape[ptr]);
        }
        else if (strcmp(trimmed, "loop[") == 0) {
            // start loop
            if (loop_stack_ptr < 1000) {
                loop_stack[loop_stack_ptr++] = i;
            }
        }
        else if (strcmp(trimmed, "]") == 0) {
            // end loop
            if (tape[ptr] != 0) {
                if (loop_stack_ptr > 0) {
                    i = loop_stack[loop_stack_ptr - 1];
                }
            } else {
                if (loop_stack_ptr > 0) {
                    loop_stack_ptr--;
                }
            }
        }
        else {
            printf(RED "error caught while parsing\n");
            printf(RED "at line: %s\n", trimmed);
            break;
        }
    }
    
    printf("\n");
    free(tape);
    free(code_copy);
}
