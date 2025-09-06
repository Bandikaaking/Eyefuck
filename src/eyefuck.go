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

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: eyefuck <command> [file.eyf]")
		return
	}

	mode := os.Args[1]

	switch mode {
	case "run":
		if len(os.Args) < 3 {
			fmt.Println("Please specify a file to run.")
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
		fmt.Println("Eyefuck HELP:")
		fmt.Println("  eyefuck run <file.eyf>  -> execute the Eyefuck file")
		fmt.Println("  eyefuck -i             -> interactive REPL mode")
		fmt.Println("  eyefuck about          -> information about this interpreter")
	case "about":
		fmt.Println("Eyefuck DEV 2025")
		fmt.Println("MIT license see LICENSE for more information")
		fmt.Println("Please help me motive by giving the repo a star")
		fmt.Println("github: github.com/bandikaaking")
		fmt.Println("crafted with <3 by @Bandikaaking")


	default:
		fmt.Println("Unknown mode:", mode)
	}
}

// ---------------------------
// Interactive REPL
// ---------------------------
func startREPL() {
	fmt.Println("Eyefuck DEV 2025 - REPL")
	fmt.Println("Type commands below, empty line to execute, Ctrl+C to exit")
	scanner := bufio.NewScanner(os.Stdin)
	codeLines := []string{}
	for {
		fmt.Print("> ")
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
			println("Error at line: ", line)
		}
	}
	fmt.Println()
}
