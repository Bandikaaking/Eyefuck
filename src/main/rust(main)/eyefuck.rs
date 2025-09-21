/*
HEWHEHHHEHHEHEHEHEHH

i guess i'll rewrite it in RUST!!! anddddd this is `rustc` not `cargo`
i will write another Buidling for c# AND rust, but it is late and i am lazy

fact: you can actully

rustc eyefuck.rs -o eyefuck

generated an eyefuck.exe (or eyefuck.o)

and then paste it to c:\windows (or sudo cp eyefuck.o /usr/local/bin)

and BUMMM you now have eyefuck locally installed from the rust code

and i recomend doing the buildwin.bat, becuse it is more safer

and enjoy eyefuck

know what? i am gonna use this instead of the go one

*/

use std::env;
use std::fs;
use std::io::{self, Read, Write};
use std::process;

mod colors
{
    pub const RESET: &str = "\x1b[0m";
    pub const RED: &str = "\x1b[31m";
    pub const GREEN: &str = "\x1b[32m";
    pub const YELLOW: &str = "\x1b[33m";
    pub const BLUE: &str = "\x1b[34m";
    pub const MAGENTA: &str = "\x1b[35m";
    pub const CYAN: &str = "\x1b[36m";
    pub const WHITE: &str = "\x1b[37m";
    pub const BRIGHT_BLACK: &str = "\x1b[90m";
    pub const BRIGHT_RED: &str = "\x1b[91m";
    pub const BRIGHT_GREEN: &str = "\x1b[92m";
    pub const BRIGHT_YELLOW: &str = "\x1b[93m";
    pub const BRIGHT_BLUE: &str = "\x1b[94m";
    pub const BRIGHT_MAGENTA: &str = "\x1b[95m";
    pub const BRIGHT_CYAN: &str = "\x1b[96m";
    pub const BRIGHT_WHITE: &str = "\x1b[97m"; //nonsene, why did i wrote this?
    pub const BG_RED: &str = "\x1b[41m";
    pub const BG_GREEN: &str = "\x1b[42m";
    pub const BG_YELLOW: &str = "\x1b[43m";
    pub const BG_BLUE: &str = "\x1b[44m";
    pub const BG_MAGENTA: &str = "\x1b[45m";
    pub const BG_CYAN: &str = "\x1b[46m";
    pub const BG_WHITE: &str = "\x1b[47m"; // this is nonsense too
    pub const UNDERL: &str = "\x1b[4m";
    pub const BLINK: &str = "\x1b[5m";
    pub const INVERT: &str = "\x1b[7m";
}


use colors::*;

const EYF_V: f64 = 1.5;
const TAPE_SIZE: usize = 30000000;

fn main() 
{
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 
    {
        println!("{}Usage:{} eyefuck <command> [file.eyf]", RED, RESET);
        return;
    }

    let mode = &args[1];

    match mode.as_str() 
    {
        "run" => 
        {
            if args.len() < 3 
            {
                println!("{}Please specify a file to run.{}", RED, RESET);
                return;
            }
            let file = &args[2];
            let code = match fs::read_to_string(file) 
            {
                Ok(content) => content,
                Err(e) => 
                {
                    eprintln!("Error reading file: {}", e);
                    return;
                }
            };
            run_interpreter(&code);
        }
        "-i" | "--i" | "i" | "REPL" | "repl" | "-repl" | "--repl" | "--REPL" => 
        {
            repl();
        }
        "help" | "-help" | "-h" | "--h" | "--help" => 
        {
            println!("{}Eyefuck HELP:{}", CYAN, RESET);
            println!("{}  eyefuck run <file.eyf>{}  -> {}execute the Eyefuck file{}", YELLOW, RESET, GREEN, RESET);
            println!("{}  eyefuck -i{}             -> {}interactive REPL mode{}", YELLOW, RESET, GREEN, RESET);
            println!("{}  eyefuck about{}          -> {}information about this interpreter{}", YELLOW, RESET, GREEN, RESET);
        }
        "about" => 
        {
            println!("{}Eyefuck DEV 2025{}", CYAN, RESET);
            println!("{}MIT license{} see LICENSE for more information", GREEN, RESET);
            println!("Please help me motive by giving the repo a star");
            println!("{}github:{} github.com/bandikaaking", BLUE, RESET);
            println!("crafted with {}<3{} by {}@Bandikaaking{}", RED, RESET, YELLOW, RESET);
        }
        "version" | "--v" | "--version" | "-v" | "v" | "-version" => 
        {
            println!("{}Current {}eyefuck {}version: {}{}", CYAN, GREEN, BRIGHT_CYAN, EYF_V, RESET);
        }
        "ov" | "--ov" | "-ov"  =>
        {
            println!("{}{}Other eyefuck versions{}", UNDERL,BG_CYAN, RESET);
            println!("{}0.10 | 0.11 | 0.13 | 0.20 | 1.01 | 1.2 | 1.3 | 1.4 | 1.4.2 | 1.5{}", BRIGHT_YELLOW,RESET);
        }
        _ => 
        {
            println!("{}Unknown {}mode:{} {}", RED, CYAN, RESET, mode);
        }
    }
}

// ---------------------------
// Interactive REPL
// ---------------------------
fn repl() 
{
    println!("{}Eyefuck DEV 2025 - REPL{}", CYAN, RESET);
    println!("Type commands below, empty line to execute, Ctrl+C to exit");
    
    let mut code_lines = Vec::new();
    
    loop 
    {
        print!("> ");
        io::stdout().flush().unwrap();
        
        let mut line = String::new();
        match io::stdin().read_line(&mut line) 
        {
            Ok(0) => break,
            Ok(_) => 
            {
                let line = line.trim().to_string();
                if line.is_empty() 
                {
                    run_interpreter(&code_lines.join("\n"));
                    code_lines.clear();
                    continue;
                }
                code_lines.push(line);
            }
            Err(e) => 
            {
                eprintln!("Error reading input: {}", e);
                break;
            }
        }
    }
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
fn run_interpreter(code: &str) 
{
    let mut tape = vec![0u8; TAPE_SIZE];
    let mut ptr = 0;
    let lines: Vec<&str> = code.lines().collect();
    let mut loop_stack: Vec<usize> = Vec::new();
    let mut i = 0;

    while i < lines.len() 
    {
        let mut line = lines[i].trim();

        // remove comments after #
        if let Some(comment_pos) = line.find('#') 
        {
            line = &line[..comment_pos].trim();
        }

        if line.is_empty() 
        {
            i += 1;
            continue;
        }

        match line 
        {
            "^" => 
            {
                tape[ptr] = tape[ptr].wrapping_add(1);
            }
            "v" => 
            {
                tape[ptr] = tape[ptr].wrapping_sub(1);
            }
            ">" => 
            {
                ptr = (ptr + 1) % TAPE_SIZE;
            }
            "<" => 
            {
                ptr = if ptr == 0 { TAPE_SIZE - 1 } else { ptr - 1 };
            }
            "," => 
            {
                let mut input = [0u8; 1];
                if let Ok(_) = io::stdin().read_exact(&mut input) 
                {
                    tape[ptr] = input[0];
                }
            }
            "." => 
            {
                print!("{}", tape[ptr] as char);
                io::stdout().flush().unwrap();
            }
            "loop[" => 
            {
                loop_stack.push(i);
            }
            "]" => 
            {
                if tape[ptr] != 0 
                {
                    if let Some(&loop_start) = loop_stack.last() 
                    {
                        i = loop_start;
                    } 
                    else 
                    {
                        eprintln!("Unmatched ]");
                        process::exit(1);
                    }
                } 
                else 
                {
                    loop_stack.pop();
                }
            }
            _ if line.starts_with("bin") => 
            {
                let bin = line[3..].trim();
                match u8::from_str_radix(bin, 2) 
                {
                    Ok(val) => tape[ptr] = val,
                    Err(_) => 
                    {
                        eprintln!("{}Invalid binary: {}",GREEN , bin);
                        process::exit(1);
                    }
                }
            }
            _ if line.starts_with("col") => 
            {
                if let Some(start) = line.find('[') 
                {
                    if let Some(end) = line.find(']') 
                    {
                        if end > start + 1 
                        {
                            let hex = &line[start+1..end];
                            match u32::from_str_radix(hex, 16) 
                            {
                                Ok(color_int) => 
                                {
                                    let r = (color_int >> 16) & 0xFF;
                                    let g = (color_int >> 8) & 0xFF;
                                    let b = color_int & 0xFF;
                                    print!("\x1b[38;2;{};{};{}m", r, g, b);
                                }
                                Err(_) => 
                                {
                                    eprintln!("Invalid HEX color");
                                    process::exit(1);
                                }
                            }
                        }
                    }
                }
            }
            _ if line.starts_with("load[") => 
            {
                if let Some(start) = line.find('[') 
                {
                    if let Some(end) = line.find(']') 
                    {
                        if end > start + 1 
                        {
                            let filename = &line[start+1..end];
                            match fs::read(filename) 
                            {
                                Ok(_) => tape[ptr] = 0,
                                Err(e) => 
                                {
                                    eprintln!("Error loading file: {}", e);
                                    process::exit(1);
                                }
                            }
                        }
                    }
                }
            }
            _ => 
            {
                eprintln!("{}error caught while parsing", RED);
                eprintln!("{}at line: {}", RED, line);
                process::exit(1);
            }
        }
        i += 1;
    }
    println!();
}
/* why am i doing this.... */
