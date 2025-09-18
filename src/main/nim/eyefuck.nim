# how are you?

import os, strutils, strformat, parseutils, re, terminal

# ANSI colors
const
  Reset = "\e[0m"
  Red = "\e[31m"
  Green = "\e[32m"
  Yellow = "\e[33m"
  Blue = "\e[34m"
  Cyan = "\e[36m"
  White = "\e[97m"

const
  EyfV = 1.2
  TapeSize = 300000

# ---------------------------
# Main function
# ---------------------------
proc main() =
  if paramCount() < 1:
    echo Red & "Usage:" & Reset & " eyefuck <command> [file.eyf]"
    return

  let mode = paramStr(1)

  case mode
  of "run":
    if paramCount() < 2:
      echo Red & "Please specify a file to run." & Reset
      return
    let file = paramStr(2)
    try:
      let code = readFile(file)
      runInterpreter(code)
    except IOError:
      echo "Error reading file: ", getCurrentExceptionMsg()
  of "-i", "--i", "i":
    startREPL()
  of "help", "-help", "-h", "--h", "--help":
    echo Cyan & "Eyefuck HELP:" & Reset
    echo Yellow & "  eyefuck run <file.eyf>" & Reset & "  -> " & Green & "execute the Eyefuck file" & Reset
    echo Yellow & "  eyefuck -i" & Reset & "             -> " & Green & "interactive REPL mode" & Reset
    echo Yellow & "  eyefuck about" & Reset & "          -> " & Green & "information about this interpreter" & Reset
  of "about":
    echo Cyan & "Eyefuck DEV 2025" & Reset
    echo Green & "MIT license" & Reset & " see LICENSE for more information"
    echo "Please help me motive by giving the repo a star"
    echo Blue & "github:" & Reset & " github.com/bandikaaking"
    echo "crafted with " & Red & "<3" & Reset & " by " & Yellow & "@Bandikaaking" & Reset
  of "version", "--v", "--version", "-v", "v", "-version":
    echo "Current eyefuck version: ", EyfV
  of "ov", "-ov", "--ov":
    echo "Other Eyefuck versions: "
    echo "0.10: Started / added 2 instructions"
    echo "0.11-0.43: Fixed many bugs, and edded 5 more instructions"
    echo "1.0: Added syntax highliting"
    echo "1.1: Fixed bugs"
    echo "added more eyefuck modes / rewrited README.md"
  else:
    echo Red & "Unknown mode:" & Reset, " ", mode

# ---------------------------
# Interactive REPL
# ---------------------------
proc startREPL() =
  echo Cyan & "Eyefuck DEV 2025 - REPL" & Reset
  echo "Type commands below, empty line to execute, Ctrl+C to exit"
  
  var codeLines: seq[string] = @[]
  
  while true:
    stdout.write("$ ")
    let line = stdin.readLine()
    
    if line.strip().len == 0:
      runInterpreter(codeLines.join("\n"))
      codeLines = @[]
      continue
    
    codeLines.add(line)

# ---------------------------
# Eyefuck Interpreter
# ---------------------------
proc runInterpreter(code: string) =
  var tape = newSeq[byte](TapeSize)
  var ptr = 0
  let lines = code.splitLines()
  var loopStack: seq[int] = @[]
  var i = 0

  while i < lines.len:
    var line = lines[i].strip()
    
    # remove comments after #
    let commentPos = line.find('#')
    if commentPos != -1:
      line = line[0..<commentPos].strip()
    
    if line.len == 0:
      inc i
      continue

    case line
    of "^": # increment cell
      inc tape[ptr]
    of "v": # decrement cell
      dec tape[ptr]
    of ">": # move pointer right
      ptr = (ptr + 1) mod TapeSize
    of "<": # move pointer left
      ptr = if ptr == 0: TapeSize - 1 else: ptr - 1
    else:
      if line.startsWith("bin"):
        # set cell from binary
        let binStr = line[3..^1].strip()
        try:
          tape[ptr] = byte(parseBinInt(binStr))
        except ValueError:
          echo "Invalid binary format"
          return
      elif line.startsWith("col"):
        # set text color from HEX
        let matches = line.findAll(re"\[([0-9A-Fa-f]+)\]")
        if matches.len > 0:
          let hexStr = matches[0][1..^2] # Remove brackets
          try:
            let colorInt = parseHexInt(hexStr)
            let r = (colorInt shr 16) and 0xFF
            let g = (colorInt shr 8) and 0xFF
            let b = colorInt and 0xFF
            stdout.write(fmt"\e[38;2;{r};{g};{b}m")
          except ValueError:
            echo "Invalid HEX color"
            return
      elif line.startsWith("load["):
        # load file
        let matches = line.findAll(re"\[([^\]]+)\]")
        if matches.len > 0:
          let filename = matches[0][1..^2] # Remove brackets
          try:
            discard readFile(filename)
            tape[ptr] = 0
          except IOError:
            echo "Error loading file"
            return
      elif line == ",":
        # read single byte input
        let input = stdin.readChar()
        tape[ptr] = byte(ord(input))
      elif line == ".":
        # print cell as char
        stdout.write(char(tape[ptr]))
      elif line == "loop[":
        # start loop
        loopStack.add(i)
      elif line == "]":
        # end loop
        if tape[ptr] != 0:
          if loopStack.len > 0:
            i = loopStack[^1]
          else:
            echo "Unmatched ]"
            return
        else:
          if loopStack.len > 0:
            discard loopStack.pop()
      else:
        echo Red & "error caught while parsing"
        echo Red & "at line: ", line
        return
    
    inc i
  
  echo ""

when isMainModule:
  main()
#good job Andrew i guess