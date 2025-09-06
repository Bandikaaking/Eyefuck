package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

// ---------------------------
// EyeFuck Interpreter Logic
// ---------------------------

// Memory and pointer
const memSize = 30000
var memory [memSize]int
var ptr int

// Shortcuts for increment/decrement
var shortcuts = map[string]int{
	"!":  10,
	"/":  1,
	"!!": 20,
	"//": 2,
}

// Simple pseudo-random generator
var seed int64 = 1
func randSeed() float64 {
	seed = (seed*9301 + 49297) % 233280
	return float64(seed) / 233280.0
}
func randInt(min, max int) int {
	return min + int(float64(max-min+1)*randSeed())
}

// Get value after ^ or v commands
func getValue(code string, i *int) int {
	val := 0
	for *i < len(code) {
		c := string(code[*i])
		if c == "!" || c == "/" {
			// check for double character shortcut
			if *i+1 < len(code) && code[*i+1] == c[0] {
				val += shortcuts[c+c]
				*i++
			} else {
				val += shortcuts[c]
			}
		} else {
			break
		}
		*i--
		*i++
	}
	return val
}

// Run EyeFuck code
func Run(code string) {
	loopStack := []int{} // stack to track loop positions

	for i := 0; i < len(code); i++ {
		c := string(code[i])
		switch c {
		case "#":
			continue //yeah.. continue
		case ">":
			ptr++
			if ptr >= memSize {
				ptr = 0
			}
		case "<":
			ptr--
			if ptr < 0 {
				ptr = memSize - 1
			}
		case "^":
			val := getValue(code, &i)
			memory[ptr] += val
		case "v":
			val := getValue(code, &i)
			memory[ptr] -= val
		case ".":
			fmt.Print(memory[ptr])
		case ":":
			fmt.Print(string(rune(memory[ptr])))
		case "?":
			memory[ptr] = randInt(0, 255)
		case "[":
			if memory[ptr] == 0 {
				level := 1
				for level > 0 {
					i++
					if i >= len(code) {
						log.Fatal("Loop mismatch: [ without ]")
					}
					if string(code[i]) == "[" {
						level++
					} else if string(code[i]) == "]" {
						level--
					}
				}
			} else {
				loopStack = append(loopStack, i)
			}
		case "]":
			if memory[ptr] != 0 {
				if len(loopStack) == 0 {
					log.Fatal("Loop mismatch: ] without [")
				}
				i = loopStack[len(loopStack)-1]
			} else {
				loopStack = loopStack[:len(loopStack)-1]
			}
		}
	}
}

// ---------------------------
// Main CLI
// ---------------------------
func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage:")
		fmt.Println("  eyefuck run <file.eyf>")
		fmt.Println("  eyefuck help")
		fmt.Println("  eyefuck about")
		return
	}

	mode := os.Args[1]

	switch mode {
	case "run":
		// Make sure the user provided a file
		if len(os.Args) < 3 {
			fmt.Println("Please provide a .eyf file to run")
			return
		}

		file := os.Args[2]

		// Read the file content
		data, err := ioutil.ReadFile(file)
		if err != nil {
			log.Fatal(err)
		}
		code := string(data)

		// Run the EyeFuck interpreter
		Run(code)

	case "help":
		fmt.Println("To use EyeFuck interpreter:")
		fmt.Println("  eyefuck run <file.eyf>   - Run an EyeFuck program")
		fmt.Println("  eyefuck help             - Show this help message")
		fmt.Println("  eyefuck about            - About the EyeFuck interpreter")

	case "about":
		fmt.Println("The EyeFuck interpreter:")
		fmt.Println("  Made by github.com/bandikaaking")
		fmt.Println("  Crafted with <3")
		fmt.Println("  Please help me motivate, by adding a star ⭐")
		fmt.Println("  MIT LICENSE see LICENSE for more information! EyeFuck Dev (C) 2025")

	default:
		fmt.Println("Unknown mode:", mode)
		fmt.Println("Use 'eyefuck help' to see usage instructions")
	}
}
