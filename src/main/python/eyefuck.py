# i actully HATE python
# i have no idea of WHY
import sys
import os
import re

# ANSI colors
RESET = "\033[0m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
CYAN = "\033[36m"
WHITE = "\033[97m"

EYF_V = 1.2
TAPE_SIZE = 300000

def main():
    if len(sys.argv) < 2:
        print(f"{RED}Usage:{RESET} eyefuck <command> [file.eyf]")
        return

    mode = sys.argv[1]

    if mode == "run":
        if len(sys.argv) < 3:
            print(f"{RED}Please specify a file to run.{RESET}")
            return
        file = sys.argv[2]
        try:
            with open(file, 'r') as f:
                code = f.read()
            run_interpreter(code)
        except Exception as e:
            print(f"Error reading file: {e}")
    elif mode in ["-i", "--i", "i"]:
        start_repl()
    elif mode in ["help", "-help", "-h", "--h", "--help"]:
        print(f"{CYAN}Eyefuck HELP:{RESET}")
        print(f"{YELLOW}  eyefuck run <file.eyf>{RESET}  -> {GREEN}execute the Eyefuck file{RESET}")
        print(f"{YELLOW}  eyefuck -i{RESET}             -> {GREEN}interactive REPL mode{RESET}")
        print(f"{YELLOW}  eyefuck about{RESET}          -> {GREEN}information about this interpreter{RESET}")
    elif mode == "about":
        print(f"{CYAN}Eyefuck DEV 2025{RESET}")
        print(f"{GREEN}MIT license{RESET} see LICENSE for more information")
        print("Please help me motive by giving the repo a star")
        print(f"{BLUE}github:{RESET} github.com/bandikaaking")
        print(f"crafted with {RED}<3{RESET} by {YELLOW}@Bandikaaking{RESET}")
    elif mode in ["version", "--v", "--version", "-v", "v", "-version"]:
        print(f"Current eyefuck version: {EYF_V}")
    elif mode in ["ov", "-ov", "--ov"]:
        print("Other Eyefuck versions: ")
        print("0.10: Started / added 2 instructions")
        print("0.11-0.43: Fixed many bugs, and edded 5 more instructions")
        print("1.0: Added syntax highliting")
        print("1.1: Fixed bugs")
        print("added more eyefuck modes / rewrited README.md")
    else:
        print(f"{RED}Unknown mode:{RESET} {mode}")

# ---------------------------
# Interactive REPL
# ---------------------------
def start_repl():
    print(f"{CYAN}Eyefuck DEV 2025 - REPL{RESET}")
    print("Type commands below, empty line to execute, Ctrl+C to exit")
    
    code_lines = []
    
    while True:
        try:
            line = input("$ ")
            if line.strip() == "":
                run_interpreter("\n".join(code_lines))
                code_lines = []
                continue
            code_lines.append(line)
        except EOFError:
            break
        except KeyboardInterrupt:
            print()
            break

# ---------------------------
# Eyefuck Interpreter
# ---------------------------
def run_interpreter(code):
    tape = [0] * TAPE_SIZE
    ptr = 0
    lines = code.split('\n')
    loop_stack = []
    i = 0

    while i < len(lines):
        line = lines[i].strip()
        
        # remove comments after #
        if '#' in line:
            line = line.split('#')[0].strip()
        
        if not line:
            i += 1
            continue

        if line == "^":
            # increment cell
            tape[ptr] = (tape[ptr] + 1) % 256
        elif line == "v":
            # decrement cell
            tape[ptr] = (tape[ptr] - 1) % 256
        elif line == ">":
            # move pointer right
            ptr = (ptr + 1) % TAPE_SIZE
        elif line == "<":
            # move pointer left
            ptr = ptr - 1 if ptr > 0 else TAPE_SIZE - 1
        elif line.startswith("bin"):
            # set cell from binary
            bin_str = line[3:].strip()
            try:
                tape[ptr] = int(bin_str, 2)
            except ValueError:
                print("Invalid binary format")
                return
        elif line.startswith("col"):
            # set text color from HEX
            match = re.search(r'\[([0-9A-Fa-f]+)\]', line)
            if match:
                hex_str = match.group(1)
                try:
                    color_int = int(hex_str, 16)
                    r = (color_int >> 16) & 0xFF
                    g = (color_int >> 8) & 0xFF
                    b = color_int & 0xFF
                    print(f"\033[38;2;{r};{g};{b}m", end='')
                except ValueError:
                    print("Invalid HEX color")
                    return
        elif line.startswith("load["):
            # load file
            match = re.search(r'\[([^\]]+)\]', line)
            if match:
                filename = match.group(1)
                try:
                    with open(filename, 'rb') as f:
                        f.read()
                    tape[ptr] = 0
                except FileNotFoundError:
                    print("Error loading file")
                    return
        elif line == ",":
            # read single byte input
            try:
                input_char = sys.stdin.read(1)
                if input_char:
                    tape[ptr] = ord(input_char)
            except:
                pass
        elif line == ".":
            # print cell as char
            print(chr(tape[ptr]), end='')
        elif line == "loop[":
            # start loop
            loop_stack.append(i)
        elif line == "]":
            # end loop
            if tape[ptr] != 0:
                if loop_stack:
                    i = loop_stack[-1]
                else:
                    print("Unmatched ]")
                    return
            else:
                if loop_stack:
                    loop_stack.pop()
        else:
            print(f"{RED}error caught while parsing")
            print(f"{RED}at line: {line}{RESET}")
            return
        
        i += 1
    
    print()

if __name__ == "__main__":
    main()
#good job Andrew i guess