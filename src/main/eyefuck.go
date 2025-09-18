/** 
* BAHHH
i am hungry as fuck, but i guesssssssssssss i have to do this...... welp, it's been 2 weeks and repo's got no star
i'll just go and eat. 
*/

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
	EyfV := 1.2
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
	case "-i", "--i", "i":
		startREPL()
	case "help", "-help", "-h", "--h", "--help":
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
	case "version", "--v", "--version", "-v", "v", "-version":
		fmt.Println("Current eyefuck version: %v", EyfV)
	//other versions and a lil' descriptions
	case "ov", "-ov", "--ov":
		fmt.Println("Other Eyefuck versions: ")
		fmt.Println("0.10: Started / added 2 instructions")
		fmt.Println("0.11-0.43: Fixed many bugs, and edded 5 more instructions")
		fmt.Println("1.0: Added syntax highliting")
		fmt.Println("1.1: Fixed bugs")
		fmt.Println("added more eyefuck modes / rewrited README.md")
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
	tape := make([]byte, 300000)
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
		case line == "^": // increment cell
			tape[ptr]++
		case line == "v": // decrement cell
			tape[ptr]--
		case line == ">": // move pointer right
			ptr++
			if ptr >= len(tape) {
				ptr = 0
			}
		case line == "<": // move pointer left
			if ptr <= 0 {
				ptr = len(tape) - 1
			} else {
				ptr--
			}
		case strings.HasPrefix(line, "bin"): // set cell from binary
			bin := strings.TrimSpace(line[4:])
			val, err := strconv.ParseInt(bin, 2, 8)
			if err != nil {
				log.Fatal(err)
			}
			tape[ptr] = byte(val)
		case strings.HasPrefix(line, "col"): // set text color from HEX
			start := strings.Index(line, "[")
			end := strings.Index(line, "]")
			if start == -1 || end == -1 || end <= start+1 {
				log.Fatal("Invalid col syntax")
			}
			hex := line[start+1 : end]
			colorInt, err := strconv.ParseInt(hex, 16, 32)
			if err != nil {
				log.Fatal("Invalid HEX color")
			}
			r := (colorInt >> 16) & 0xFF
			g := (colorInt >> 8) & 0xFF
			b := colorInt & 0xFF
			fmt.Printf("\033[38;2;%d;%d;%dm", r, g, b)
		case strings.HasPrefix(line, "load["): // load file
			start := strings.Index(line, "[")
			end := strings.Index(line, "]")
			if start == -1 || end == -1 || end <= start+1 {
				log.Fatal("Invalid load syntax")
			}
			filename := line[start+1 : end]
			data, err := ioutil.ReadFile(filename)
			if err != nil {
				log.Fatal(err)
			}
			tape[ptr] = 0
			_ = data
		case line == ",": // read single byte input
			var b [1]byte
			os.Stdin.Read(b[:])
			tape[ptr] = b[0]
		case line == ".": // print cell as char
			fmt.Printf("%c", tape[ptr])
		case strings.HasPrefix(line, "loop["): // start loop
			loopStack = append(loopStack, i)
		case line == "]": // end loop
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
//good job Andrew i guess
