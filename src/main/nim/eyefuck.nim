# i don't know... nim is, not my favorite (like lua). But i don't hate it (like python)
# it is like... idk 

# there is a problem with it, and i will not fix it!
import os, strutils, strformat, re

const
  Reset = "\e[0m"
  Red = "\e[31m"
  Green = "\e[32m"
  Yellow = "\e[33m"
  Blue = "\e[34m"
  Cyan = "\e[36m"


const
  EyfV = 1.2
  TapeSize = 300000

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
      if tape[ptr] > 0:  # Prevent underflow
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
          stderr.writeLine "Invalid binary format: " & binStr
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
            stderr.writeLine "Invalid HEX color: " & hexStr
            return
      elif line.startsWith("load["):
        # load file
        let matches = line.findAll(re"\[([^\]]+)\]")
        if matches.len > 0:
          let filename = matches[0][1..^2] # Remove brackets
          try:
            let content = readFile(filename)
            # Store first character of file content in current cell
            if content.len > 0:
              tape[ptr] = byte(ord(content[0]))
            else:
              tape[ptr] = 0
          except IOError:
            stderr.writeLine "Error loading file: " & filename
            return
      elif line == ",":
        # read single byte input
        try:
          let input = stdin.readChar()
          tape[ptr] = byte(ord(input))
        except IOError:
          tape[ptr] = 0  # EOF or error case
      elif line == ".":
        # print cell as char
        stdout.write(char(tape[ptr]))
      elif line == "loop[":
        # start loop
        loopStack.add(i)
      elif line == "]":
        # end loop
        if loopStack.len == 0:
          stderr.writeLine "Unmatched ] at line " & $i
          return
        if tape[ptr] != 0:
          i = loopStack[^1]
        else:
          discard loopStack.pop()
      else:
        stderr.writeLine Red & "error caught while parsing"
        stderr.writeLine Red & "at line: " & $i & ": " & line
        return
    
    inc i
  
  stdout.write(Reset)  # Reset color at end
  stdout.writeLine("")  # Ensure newline at end

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
      if codeLines.len > 0:
        runInterpreter(codeLines.join("\n"))
      codeLines = @[]
      continue
    
    codeLines.add(line)

# ---------------------------
# Main function
# ---------------------------
proc main() =
  if paramCount() < 1:
    echo Red & "Usage:" & Reset & " eyefuck <command> [file.eyf]"
    echo "Commands: run, -i, help, about, version, ov"
    quit(1)

  let mode = paramStr(1)

  case mode
  of "run":
    if paramCount() < 2:
      echo Red & "Please specify a file to run." & Reset
      quit(1)
    let file = paramStr(2)
    if not fileExists(file):
      echo "File not found: ", file
      quit(1)
    try:
      let code = readFile(file)
      runInterpreter(code)
    except IOError:
      echo "Error reading file: ", getCurrentExceptionMsg()
      quit(1)
  of "-i", "--i", "i":
    startREPL()
  of "help", "-help", "-h", "--h", "--help":
    echo Cyan & "Eyefuck HELP:" & Reset
    echo Yellow & "  eyefuck run <file.eyf>" & Reset & "  -> " & Green & "execute the Eyefuck file" & Reset
    echo Yellow & "  eyefuck -i" & Reset & "             -> " & Green & "interactive REPL mode" & Reset
    echo Yellow & "  eyefuck about" & Reset & "          -> " & Green & "information about this interpreter" & Reset
    echo Yellow & "  eyefuck version" & Reset & "        -> " & Green & "show version information" & Reset
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
    echo "Use 'eyefuck help' for available commands."
    quit(1)

when isMainModule:
  main()