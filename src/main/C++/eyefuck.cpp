/** 
Hello fellas!

here is the timeline of what file i created (only including eyefuck interpreters not building file nor LICENSE-s etc.)
(old to young)
- eyefuck.go (oldest)
- eyefuck.rs
- eyefuck.cs (or Program.cs)
- eyefuck.rb
- eyefuck.lua
- eyefuck.c
- eyefuck.cpp (youngest)

and i maked theese files under 3 days (fineshed them OFC), i AM proud of myself


*kiss for you*
*/


#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stack>
#include <sstream>
#include <cctype>
#include <cstdlib>

// ANSI colors
const std::string RESET = "\033[0m";
const std::string RED = "\033[31m";
const std::string GREEN = "\033[32m";
const std::string YELLOW = "\033[33m";
const std::string BLUE = "\033[34m";
const std::string CYAN = "\033[36m";
const std::string WHITE = "\033[97m";

const float EYF_V = 1.2f;
const int TAPE_SIZE = 300000;

// Function prototypes
void run_interpreter(const std::string& code);
void start_repl();

// ---------------------------
// Helper function to trim strings
// ---------------------------
std::string trim(const std::string& str) {
    size_t start = str.find_first_not_of(" \t\n\r");
    if (start == std::string::npos) return "";
    size_t end = str.find_last_not_of(" \t\n\r");
    return str.substr(start, end - start + 1);
}

// ---------------------------
// Main function
// ---------------------------
int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << RED << "Usage:" << RESET << " eyefuck <command> [file.eyf]" << std::endl;
        return 1;
    }

    std::string mode = argv[1];

    if (mode == "run") {
        if (argc < 3) {
            std::cout << RED << "Please specify a file to run." << RESET << std::endl;
            return 1;
        }
        std::string file = argv[2];
        std::ifstream infile(file);
        if (!infile) {
            std::cerr << "Error opening file: " << file << std::endl;
            return 1;
        }
        std::stringstream buffer;
        buffer << infile.rdbuf();
        std::string code = buffer.str();
        infile.close();
        run_interpreter(code);
    }
    else if (mode == "-i" || mode == "--i" || mode == "i") {
        start_repl();
    }
    else if (mode == "help" || mode == "-help" || mode == "-h" || mode == "--h" || mode == "--help") {
        std::cout << CYAN << "Eyefuck HELP:" << RESET << std::endl;
        std::cout << YELLOW << "  eyefuck run <file.eyf>" << RESET << "  -> " << GREEN << "execute the Eyefuck file" << RESET << std::endl;
        std::cout << YELLOW << "  eyefuck -i" << RESET << "             -> " << GREEN << "interactive REPL mode" << RESET << std::endl;
        std::cout << YELLOW << "  eyefuck about" << RESET << "          -> " << GREEN << "information about this interpreter" << RESET << std::endl;
    }
    else if (mode == "about") {
        std::cout << CYAN << "Eyefuck DEV 2025" << RESET << std::endl;
        std::cout << GREEN << "MIT license" << RESET << " see LICENSE for more information" << std::endl;
        std::cout << "Please help me motive by giving the repo a star" << std::endl;
        std::cout << BLUE << "github:" << RESET << " github.com/bandikaaking" << std::endl;
        std::cout << "crafted with " << RED << "<3" << RESET << " by " << YELLOW << "@Bandikaaking" << RESET << std::endl;
    }
    else if (mode == "version" || mode == "--v" || mode == "--version" || mode == "-v" || mode == "v" || mode == "-version") {
        std::cout << "Current eyefuck version: " << EYF_V << std::endl;
    }
    else if (mode == "ov" || mode == "-ov" || mode == "--ov") {
        std::cout << "Other Eyefuck versions: " << std::endl;
        std::cout << "0.10: Started / added 2 instructions" << std::endl;
        std::cout << "0.11-0.43: Fixed many bugs, and edded 5 more instructions" << std::endl;
        std::cout << "1.0: Added syntax highliting" << std::endl;
        std::cout << "1.1: Fixed bugs" << std::endl;
        std::cout << "added more eyefuck modes / rewrited README.md" << std::endl;
    }
    else {
        std::cout << RED << "Unknown mode:" << RESET << " " << mode << std::endl;
        return 1;
    }

    return 0;
}

// ---------------------------
// Interactive REPL
// ---------------------------
void start_repl() {
    std::cout << CYAN << "Eyefuck DEV 2025 - REPL" << RESET << std::endl;
    std::cout << "Type commands below, empty line to execute, Ctrl+C to exit" << std::endl;
    
    std::vector<std::string> code_lines;
    
    while (true) {
        std::cout << "$ ";
        std::string line;
        std::getline(std::cin, line);
        
        if (line.empty()) {
            std::string code;
            for (const auto& l : code_lines) {
                code += l + "\n";
            }
            run_interpreter(code);
            code_lines.clear();
            continue;
        }
        
        code_lines.push_back(line);
    }
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
void run_interpreter(const std::string& code) {
    std::vector<unsigned char> tape(TAPE_SIZE, 0);
    size_t ptr = 0;
    
    std::vector<std::string> lines;
    std::istringstream stream(code);
    std::string line;
    
    while (std::getline(stream, line)) {
        lines.push_back(line);
    }
    
    std::stack<size_t> loop_stack;
    
    for (size_t i = 0; i < lines.size(); i++) {
        line = lines[i];
        
        // Remove comments after #
        size_t comment_pos = line.find('#');
        if (comment_pos != std::string::npos) {
            line = line.substr(0, comment_pos);
        }
        
        line = trim(line);
        if (line.empty()) {
            continue;
        }

        if (line == "^") {
            // increment cell
            tape[ptr]++;
        }
        else if (line == "v") {
            // decrement cell
            tape[ptr]--;
        }
        else if (line == ">") {
            // move pointer right
            ptr = (ptr + 1) % TAPE_SIZE;
        }
        else if (line == "<") {
            // move pointer left
            ptr = (ptr == 0) ? TAPE_SIZE - 1 : ptr - 1;
        }
        else if (line.find("bin") == 0) {
            // set cell from binary
            std::string bin_str = trim(line.substr(3));
            try {
                tape[ptr] = std::stoi(bin_str, nullptr, 2);
            }
            catch (...) {
                std::cerr << "Invalid binary format" << std::endl;
                return;
            }
        }
        else if (line.find("col") == 0) {
            // set text color from HEX
            size_t start = line.find('[');
            size_t end = line.find(']');
            if (start != std::string::npos && end != std::string::npos && end > start + 1) {
                std::string hex = line.substr(start + 1, end - start - 1);
                try {
                    unsigned long color_int = std::stoul(hex, nullptr, 16);
                    int r = (color_int >> 16) & 0xFF;
                    int g = (color_int >> 8) & 0xFF;
                    int b = color_int & 0xFF;
                    std::cout << "\033[38;2;" << r << ";" << g << ";" << b << "m";
                }
                catch (...) {
                    std::cerr << "Invalid HEX color" << std::endl;
                    return;
                }
            }
        }
        else if (line.find("load[") == 0) {
            // load file
            size_t start = line.find('[');
            size_t end = line.find(']');
            if (start != std::string::npos && end != std::string::npos && end > start + 1) {
                std::string filename = line.substr(start + 1, end - start - 1);
                std::ifstream file(filename);
                if (file) {
                    file.close();
                    tape[ptr] = 0;
                }
            }
        }
        else if (line == ",") {
            // read single byte input
            tape[ptr] = std::cin.get();
        }
        else if (line == ".") {
            // print cell as char
            std::cout << tape[ptr];
        }
        else if (line == "loop[") {
            // start loop
            loop_stack.push(i);
        }
        else if (line == "]") {
            // end loop
            if (tape[ptr] != 0) {
                if (!loop_stack.empty()) {
                    i = loop_stack.top();
                }
            } else {
                if (!loop_stack.empty()) {
                    loop_stack.pop();
                }
            }
        }
        else {
            std::cerr << RED << "error caught while parsing" << std::endl;
            std::cerr << RED << "at line: " << line << RESET << std::endl;
            return;
        }
    }
    
    std::cout << std::endl;
}
//good job Andrew i guess