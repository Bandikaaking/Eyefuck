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
        "build" => 
        {
            if args.len() < 3 
            {
                println!("{}Please specify a file to build.{}", RED, RESET);
                return;
            }
            let file = &args[2];
            let output_name = if args.len() > 3 { &args[3] } else { "output" };
            build_to_fasm(file, output_name);
        }
        "asm" | "-S" | "--s" | "-asm" | "--asm" => 
        {
            if args.len() < 4 
            {
                println!("{}Please specify input file and output assembly file.{}", RED, RESET);
                println!("{}Usage:{} eyefuck asm <file.eyf> <output.asm>", YELLOW, RESET);
                return;
            }
            let input_file = &args[2];
            let output_file = &args[3];
            generate_asm_only(input_file, output_file);
        }
        "-i" | "--i" | "i" | "REPL" | "repl" | "-repl" | "--repl" | "--REPL" | "-REPL" => 
        {
            repl();
        }
        "help" | "-help" | "-h" | "--h" | "--help" | "h" => 
        {
            println!("{}Eyefuck HELP:{}", CYAN, RESET);
            println!("{}  eyefuck run <file.eyf>{}  -> {}execute the Eyefuck file{}", YELLOW, RESET, GREEN, RESET);
            println!("{}  eyefuck build <file.eyf> [output]{} -> {}compile to executable{}", YELLOW, RESET, GREEN, RESET);
            println!("{}  eyefuck asm <file.eyf> <output.asm>{} -> {}generate assembly file{}", YELLOW, RESET, GREEN, RESET);
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
        "version" | "--v" | "--version" | "-v" | "v" | "-version" | "ver" | "--ver" | "-ver" => 
        {
            println!("{}Current {}eyefuck {}version: {}{}", CYAN, GREEN, BRIGHT_CYAN, EYF_V, RESET);
        }
        "ov" | "--ov" | "-ov"  =>
        {
            println!("{}{}Other eyefuck versions{}", UNDERL,BRIGHT_GREEN, RESET);
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

// ---------------------------
// FASM Compiler
// ---------------------------
fn build_to_fasm(filename: &str, output_name: &str) 
{
    println!("{}Compiling {} to FASM assembly...{}", CYAN, filename, RESET);
    
    let code = match fs::read_to_string(filename) 
    {
        Ok(content) => content,
        Err(e) => 
        {
            eprintln!("Error reading file: {}", e);
            return;
        }
    };

    let fasm_code = generate_fasm(&code, output_name);
    
    let asm_filename = format!("{}.asm", output_name);
    match fs::write(&asm_filename, fasm_code) 
    {
        Ok(_) => println!("{}FASM assembly written to {}{}", GREEN, asm_filename, RESET),
        Err(e) => 
        {
            eprintln!("Error writing assembly file: {}", e);
            return;
        }
    }

    // Compile with FASM
    compile_with_fasm(&asm_filename, output_name);
}

fn generate_fasm(code: &str, output_name: &str) -> String 
{
    let mut fasm = String::new();
    
    // FASM header for Windows
    fasm.push_str("format PE64 console\n");
    fasm.push_str("entry start\n\n");
    
    // Import section
    fasm.push_str("section '.idata' import data readable writeable\n");
    fasm.push_str("library kernel32,'KERNEL32.DLL',\\\n");
    fasm.push_str("        msvcrt,'MSVCRT.DLL'\n\n");
    fasm.push_str("import kernel32,\\\n");
    fasm.push_str("       ExitProcess,'ExitProcess',\\\n");
    fasm.push_str("       GetStdHandle,'GetStdHandle',\\\n");
    fasm.push_str("       WriteConsoleA,'WriteConsoleA',\\\n");
    fasm.push_str("       ReadConsoleA,'ReadConsoleA',\\\n");
    fasm.push_str("       GetProcessHeap,'GetProcessHeap',\\\n");
    fasm.push_str("       HeapAlloc,'HeapAlloc',\\\n");
    fasm.push_str("       HeapFree,'HeapFree'\n\n");
    
    fasm.push_str("import msvcrt,\\\n");
    fasm.push_str("       printf,'printf',\\\n");
    fasm.push_str("       getchar,'_fgetchar'\n\n");
    
    // Code section
    fasm.push_str("section '.code' code readable executable\n");
    
    fasm.push_str("start:\n");
    fasm.push_str("    ; Allocate tape memory (30,000,000 bytes)\n");
    fasm.push_str("    call [GetProcessHeap]\n");
    fasm.push_str("    mov rcx, rax\n");
    fasm.push_str("    mov rdx, 0x8 ; HEAP_ZERO_MEMORY\n");
    fasm.push_str("    mov r8, 30000000\n");
    fasm.push_str("    call [HeapAlloc]\n");
    fasm.push_str("    mov [tape_ptr], rax\n");
    fasm.push_str("    test rax, rax\n");
    fasm.push_str("    jz .exit_failure\n\n");
    
    fasm.push_str("    ; Initialize pointer\n");
    fasm.push_str("    mov dword [ptr], 0\n\n");
    
    let lines: Vec<&str> = code.lines().collect();
    let mut label_counter = 0;
    let mut loop_stack: Vec<usize> = Vec::new();
    
    for (i, line) in lines.iter().enumerate() 
    {
        let mut clean_line = line.trim();
        
        // Remove comments
        if let Some(comment_pos) = clean_line.find('#') 
        {
            clean_line = &clean_line[..comment_pos].trim();
        }
        
        if clean_line.is_empty() 
        {
            continue;
        }
        
        match clean_line 
        {
            "^" => 
            {
                fasm.push_str("    ; Increment current cell\n");
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    inc byte [rax + rcx]\n");
            }
            "v" => 
            {
                fasm.push_str("    ; Decrement current cell\n");
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    dec byte [rax + rcx]\n");
            }
            ">" => 
            {
                fasm.push_str("    ; Move pointer right\n");
                fasm.push_str("    inc dword [ptr]\n");
                fasm.push_str("    cmp dword [ptr], 30000000\n");
                fasm.push_str("    jl .no_wrap_right\n");
                fasm.push_str("    mov dword [ptr], 0\n");
                fasm.push_str(".no_wrap_right:\n");
            }
            "<" => 
            {
                fasm.push_str("    ; Move pointer left\n");
                fasm.push_str("    cmp dword [ptr], 0\n");
                fasm.push_str("    jg .no_wrap_left\n");
                fasm.push_str("    mov dword [ptr], 29999999\n");
                fasm.push_str("    jmp .wrap_done_left\n");
                fasm.push_str(".no_wrap_left:\n");
                fasm.push_str("    dec dword [ptr]\n");
                fasm.push_str(".wrap_done_left:\n");
            }
            "." => 
            {
                fasm.push_str("    ; Output character\n");
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    movzx ecx, byte [rax + rcx]\n");
                fasm.push_str("    push rcx\n");
                fasm.push_str("    call [printf]\n");
                fasm.push_str("    add rsp, 8\n");
            }
            "," => 
            {
                fasm.push_str("    ; Input character\n");
                fasm.push_str("    call [getchar]\n");
                fasm.push_str("    mov rbx, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    mov [rbx + rcx], al\n");
            }
            "loop[" => 
            {
                let label = format!("loop_{}", label_counter);
                fasm.push_str(&format!("{}:\n", label));
                fasm.push_str("    ; Check loop condition\n");
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    cmp byte [rax + rcx], 0\n");
                fasm.push_str(&format!("    je end_loop_{}\n", label_counter));
                loop_stack.push(label_counter);
                label_counter += 1;
            }
            "]" => 
            {
                if let Some(loop_id) = loop_stack.pop() 
                {
                    fasm.push_str(&format!("    ; Loop back\n"));
                    fasm.push_str("    mov rax, [tape_ptr]\n");
                    fasm.push_str("    mov ecx, [ptr]\n");
                    fasm.push_str("    cmp byte [rax + rcx], 0\n");
                    fasm.push_str(&format!("    jne loop_{}\n", loop_id));
                    fasm.push_str(&format!("end_loop_{}:\n", loop_id));
                }
            }
            _ if clean_line.starts_with("bin") => 
            {
                let bin = clean_line[3..].trim();
                if let Ok(val) = u8::from_str_radix(bin, 2) 
                {
                    fasm.push_str("    ; Set binary value\n");
                    fasm.push_str("    mov rax, [tape_ptr]\n");
                    fasm.push_str("    mov ecx, [ptr]\n");
                    fasm.push_str(&format!("    mov byte [rax + rcx], {}\n", val));
                }
            }
            _ => 
            {
                // Skip unknown commands for now
                fasm.push_str(&format!("    ; Unknown command: {}\n", clean_line));
            }
        }
        fasm.push_str("\n");
    }
    
    // Cleanup and exit
    fasm.push_str("    ; Free tape memory and exit\n");
    fasm.push_str("    call [GetProcessHeap]\n");
    fasm.push_str("    mov rcx, rax\n");
    fasm.push_str("    mov rdx, 0\n");
    fasm.push_str("    mov r8, [tape_ptr]\n");
    fasm.push_str("    call [HeapFree]\n");
    fasm.push_str("    xor ecx, ecx\n");
    fasm.push_str("    call [ExitProcess]\n\n");
    
    fasm.push_str(".exit_failure:\n");
    fasm.push_str("    mov ecx, 1\n");
    fasm.push_str("    call [ExitProcess]\n\n");
    
    // Data section
    fasm.push_str("section '.data' data readable writeable\n");
    fasm.push_str("tape_ptr dq 0\n");
    fasm.push_str("ptr dd 0\n");
    fasm.push_str("output_buffer db 0\n");
    
    fasm
}

fn generate_asm_only(input_file: &str, output_file: &str) 
{
    println!("{}Generating assembly for {}...{}", CYAN, input_file, RESET);
    
    let code = match fs::read_to_string(input_file) 
    {
        Ok(content) => content,
        Err(e) => 
        {
            eprintln!("Error reading file: {}", e);
            return;
        }
    };

    let fasm_code = generate_fasm(&code, "output");
    
    match fs::write(output_file, fasm_code) 
    {
        Ok(_) => println!("{}Assembly written to {}{}", GREEN, output_file, RESET),
        Err(e) => 
        {
            eprintln!("Error writing assembly file: {}", e);
            return;
        }
    }
}

fn compile_with_fasm(asm_filename: &str, output_name: &str) 
{
    println!("{}Assembling with FASM...{}", YELLOW, RESET);
    
    let output_file = format!("{}.exe", output_name);
    
    let status = process::Command::new("fasm")
        .arg(asm_filename)
        .arg(&output_file)
        .status();
    
    match status 
    {
        Ok(exit_status) if exit_status.success() => 
        {
            println!("{}Success! Compiled to: {}{}", GREEN, output_file, RESET);
            
            // Clean up intermediate .asm file
            let _ = fs::remove_file(asm_filename);
            println!("{}Cleaned up intermediate files{}", BRIGHT_BLACK, RESET);
        }
        Ok(exit_status) => 
        {
            eprintln!("{}FASM compilation failed with exit code: {}{}", RED, exit_status, RESET);
            eprintln!("{}Please make sure FASM is installed and in your PATH{}", YELLOW, RESET);
            
            // Show the assembly file location for debugging
            println!("{}Assembly file saved at: {}{}", YELLOW, asm_filename, RESET);
        }
        Err(e) => 
        {
            eprintln!("{}Failed to run FASM: {}{}", RED, e, RESET);
            eprintln!("{}Install FASM from: https://flatassembler.net/{}", YELLOW, RESET);
        }
    }
}

/* why am i doing this.... but now it's a compiler! */

/* 
Now you can do:
eyefuck build hello.eyf hello
And it will generate hello.exe

The .asm file is automatically cleaned up after compilation
Uses HeapAlloc for the 30,000,000 byte tape to avoid FASM limitations
*/