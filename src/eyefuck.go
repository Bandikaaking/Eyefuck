package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strconv"
	"strings"
)

// ANSI colors
const (
	Reset  = "\033[0m"
	Red    = "\033[31m"
	Green  = "\033[32m"
	Yellow = "\033[33m"
	Blue   = "\033[34m"
	Cyan   = "\033[36m"
	White  = "\033[97m"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println(Red + "Usage:" + Reset + " eyefuck <command> [file.eyf]")
		return
	}

	mode := os.Args[1]

	switch mode {
	case "run":
		if len(os.Args) < 3 {
			fmt.Println(Red + "Please specify a file to run." + Reset)
			return
		}
		file := os.Args[2]
		data, err := ioutil.ReadFile(file)
		if err != nil {
			log.Fatal(err)
		}
		code := string(data)
		runInterpreter(code)
	case "-i":
		startREPL()
	case "help":
		fmt.Println(Cyan + "Eyefuck HELP:" + Reset)
		fmt.Println(Yellow + "  eyefuck run <file.eyf>" + Reset + "  -> " + Green + "execute the Eyefuck file" + Reset)
		fmt.Println(Yellow + "  eyefuck -i" + Reset + "             -> " + Green + "interactive REPL mode" + Reset)
		fmt.Println(Yellow + "  eyefuck about" + Reset + "          -> " + Green + "information about this interpreter" + Reset)
	case "-help":
		fmt.Println(Cyan + "Eyefuck HELP:" + Reset)
		fmt.Println(Yellow + "  eyefuck run <file.eyf>" + Reset + "  -> " + Green + "execute the Eyefuck file" + Reset)
		fmt.Println(Yellow + "  eyefuck -i" + Reset + "             -> " + Green + "interactive REPL mode" + Reset)
		fmt.Println(Yellow + "  eyefuck about" + Reset + "          -> " + Green + "information about this interpreter" + Reset)
	case "-h":
		fmt.Println(Cyan + "Eyefuck HELP:" + Reset)
		fmt.Println(Yellow + "  eyefuck run <file.eyf>" + Reset + "  -> " + Green + "execute the Eyefuck file" + Reset)
		fmt.Println(Yellow + "  eyefuck -i" + Reset + "             -> " + Green + "interactive REPL mode" + Reset)
		fmt.Println(Yellow + "  eyefuck about" + Reset + "          -> " + Green + "information about this interpreter" + Reset)
	case "about":
		fmt.Println(Cyan + "Eyefuck DEV 2025" + Reset)
		fmt.Println(Green + "MIT license" + Reset + " see LICENSE for more information")
		fmt.Println("Please help me motive by giving the repo a star")
		fmt.Println(Blue + "github:" + Reset + " github.com/bandikaaking")
		fmt.Println("crafted with " + Red + "<3" + Reset + " by " + Yellow + "@Bandikaaking" + Reset)

	default:
		fmt.Println(Red + "Unknown mode:" + Reset, mode)
	}
}

// ---------------------------
// Interactive REPL
// ---------------------------
func startREPL() {
	fmt.Println(Cyan + "Eyefuck DEV 2025 - REPL" + Reset)
	fmt.Println("Type commands below, empty line to execute, Ctrl+C to exit")
	scanner := bufio.NewScanner(os.Stdin)
	codeLines := []string{}
	for {
		fmt.Print("$ ")
		if !scanner.Scan() {
			break
		}
		line := scanner.Text()
		if line == "" {
			runInterpreter(strings.Join(codeLines, "\n"))
			codeLines = []string{}
			continue
		}
		codeLines = append(codeLines, line)
	}
	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
func runInterpreter(code string) {
	tape := make([]byte, 30000)
	ptr := 0
	lines := strings.Split(code, "\n")
	loopStack := []int{}

	for i := 0; i < len(lines); i++ {
		line := lines[i]
		// remove comments after #
		if strings.Contains(line, "#") {
			line = strings.Split(line, "#")[0]
		}
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		switch {
		case line == "^":
			tape[ptr]++
		case line == "v":
			tape[ptr]--
		case line == ">":
			ptr++
			if ptr >= len(tape) {
				ptr = 0
			}
		case line == "<":
			if ptr <= 0 {
				ptr = len(tape) - 1
			} else {
				ptr--
			}
		case strings.HasPrefix(line, "set"):
			bin := strings.TrimSpace(line[4:])
			val, err := strconv.ParseInt(bin, 2, 8)
			if err != nil {
				log.Fatal(err)
			}
			tape[ptr] = byte(val)
		case line == "print":
			fmt.Printf("%c", tape[ptr])
		case line == "input":
			var input string
			fmt.Scanln(&input)
			if len(input) > 0 {
				tape[ptr] = input[0]
			} else {
				tape[ptr] = 0
			}
		case strings.HasPrefix(line, "loop["):
			loopStack = append(loopStack, i)
		case line == "]":
			if tape[ptr] != 0 {
				if len(loopStack) == 0 {
					log.Fatal("Unmatched ]")
				}
				i = loopStack[len(loopStack)-1]
			} else {
				if len(loopStack) > 0 {
					loopStack = loopStack[:len(loopStack)-1]
				}
			}
		default:
			println(Red + "error caught while parsing")
			println(Red + "at line: ", line)
		}
	}
	fmt.Println()
}
