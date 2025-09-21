(*
i actully love f# but i only learned it for 2 years
*)

open System
open System.IO
open System.Text.RegularExpressions

// ANSI colors
let RESET = "\u001b[0m"
let RED = "\u001b[31m"
let GREEN = "\u001b[32m"
let YELLOW = "\u001b[33m"
let BLUE = "\u001b[34m"
let CYAN = "\u001b[36m"
let WHITE = "\u001b[97m"

let EYF_V = 1.2
let TAPE_SIZE = 300000

// ---------------------------
// Main function
// ---------------------------
[<EntryPoint>]
let main argv =
    if argv.Length < 1 then
        printfn "%sUsage:%s eyefuck <command> [file.eyf]" RED RESET
        1
    else
        let mode = argv.[0]

        match mode with
        | "run" ->
            if argv.Length < 2 then
                printfn "%sPlease specify a file to run.%s" RED RESET
                1
            else
                let file = argv.[1]
                try
                    let code = File.ReadAllText(file)
                    runInterpreter code
                    0
                with
                | e ->
                    printfn "Error reading file: %s" e.Message
                    1

        | "-i" | "--i" | "i" ->
            startREPL()
            0

        | "help" | "-help" | "-h" | "--h" | "--help" ->
            printfn "%sEyefuck HELP:%s" CYAN RESET
            printfn "%s  eyefuck run <file.eyf>%s  -> %sexecute the Eyefuck file%s" YELLOW RESET GREEN RESET
            printfn "%s  eyefuck -i%s             -> %sinteractive REPL mode%s" YELLOW RESET GREEN RESET
            printfn "%s  eyefuck about%s          -> %sinformation about this interpreter%s" YELLOW RESET GREEN RESET
            0

        | "about" ->
            printfn "%sEyefuck DEV 2025%s" CYAN RESET
            printfn "%sMIT license%s see LICENSE for more information" GREEN RESET
            printfn "Please help me motive by giving the repo a star"
            printfn "%sgithub:%s github.com/bandikaaking" BLUE RESET
            printfn "crafted with %s<3%s by %s@Bandikaaking%s" RED RESET YELLOW RESET
            0

        | "version" | "--v" | "--version" | "-v" | "v" | "-version" ->
            printfn "Current eyefuck version: %f" EYF_V
            0

        | "ov" | "-ov" | "--ov" ->
            printfn "Other Eyefuck versions: "
            printfn "0.10: Started / added 2 instructions"
            printfn "0.11-0.43: Fixed many bugs, and edded 5 more instructions"
            printfn "1.0: Added syntax highliting"
            printfn "1.1: Fixed bugs"
            printfn "added more eyefuck modes / rewrited README.md"
            0

        | _ ->
            printfn "%sUnknown mode:%s %s" RED RESET mode
            1

// ---------------------------
// Interactive REPL
// ---------------------------
let startREPL () =
    printfn "%sEyefuck DEV 2025 - REPL%s" CYAN RESET
    printfn "Type commands below, empty line to execute, Ctrl+C to exit"
    
    let rec readLines lines =
        printf "$ "
        let line = Console.ReadLine()
        
        if String.IsNullOrWhiteSpace(line) then
            runInterpreter (String.Join("\n", List.rev lines))
            readLines []
        else
            readLines (line :: lines)
    
    try
        readLines []
    with
    | _ -> ()

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
let runInterpreter (code: string) =
    let tape = Array.zeroCreate<byte> TAPE_SIZE
    let mutable ptr = 0
    let lines = code.Split('\n')
    let mutable loopStack = []
    let mutable i = 0

    while i < lines.Length do
        let line = lines.[i].Trim()
        
        // remove comments after #
        let line = 
            match line.IndexOf('#') with
            | -1 -> line
            | idx -> line.Substring(0, idx).Trim()
        
        if not (String.IsNullOrEmpty(line)) then
            match line with
            | "^" -> // increment cell
                tape.[ptr] <- tape.[ptr] + 1uy
            | "v" -> // decrement cell
                tape.[ptr] <- tape.[ptr] - 1uy
            | ">" -> // move pointer right
                ptr <- (ptr + 1) % TAPE_SIZE
            | "<" -> // move pointer left
                ptr <- if ptr = 0 then TAPE_SIZE - 1 else ptr - 1
            | line when line.StartsWith("bin") -> // set cell from binary
                let binStr = line.Substring(3).Trim()
                try
                    tape.[ptr] <- Convert.ToByte(binStr, 2)
                with
                | _ -> 
                    printfn "Invalid binary format"
                    exit 1
            | line when line.StartsWith("col") -> // set text color from HEX
                let m = Regex.Match(line, @"\[([0-9A-Fa-f]+)\]")
                if m.Success then
                    let hex = m.Groups.[1].Value
                    try
                        let colorInt = Convert.ToInt32(hex, 16)
                        let r = (colorInt >>> 16) &&& 0xFF
                        let g = (colorInt >>> 8) &&& 0xFF
                        let b = colorInt &&& 0xFF
                        printf "\u001b[38;2;%d;%d;%dm" r g b
                    with
                    | _ -> 
                        printfn "Invalid HEX color"
                        exit 1
            | line when line.StartsWith("load[") -> // load file
                let m = Regex.Match(line, @"\[([^\]]+)\]")
                if m.Success then
                    let filename = m.Groups.[1].Value
                    try
                        File.ReadAllBytes(filename) |> ignore
                        tape.[ptr] <- 0uy
                    with
                    | _ -> 
                        printfn "Error loading file"
                        exit 1
            | "," -> // read single byte input
                let input = Console.Read()
                if input <> -1 then
                    tape.[ptr] <- byte input
            | "." -> // print cell as char
                printf "%c" (char tape.[ptr])
            | "loop[" -> // start loop
                loopStack <- i :: loopStack
            | "]" -> // end loop
                if tape.[ptr] <> 0uy then
                    match loopStack with
                    | head :: tail ->
                        i <- head
                        loopStack <- tail
                    | [] ->
                        printfn "Unmatched ]"
                        exit 1
                else
                    loopStack <- List.tail loopStack
            | _ ->
                printfn "%serror caught while parsing" RED
                printfn "%sat line: %s" RED line
                exit 1
        
        i <- i + 1
    
    printfn ""

