/*
HEWHEHHHEHHEHEHEHEHH

i guess i'll rewrite it in RUST!!! anddddd this is `rustc` not `cargo`
i will write another Buidling for c# AND rust, but it is late and i am lazy

fact: you can actually

rustc eyefuck.rs -o eyefuck

generated an eyefuck.exe (or eyefuck.o)

and then paste it to c:\windows (or sudo cp eyefuck.o /usr/local/bin)

and BUMMM you now have eyefuck locally installed from the rust code

and i recomend doing the buildwin.bat, becuse it is more safer

and enjoy eyefuck

know what? i am gonna use this instead of the "go" one

*/

use std::env;
use std::fs;
use std::io::{self, Read, Write};
use std::process;

// Cross-platform ANSI color support without external crates
mod colors {
    use std::sync::Once;

    static INIT: Once = Once::new();
    static mut COLORS_ENABLED: bool = false;

    fn init_colors() -> bool {
        #[cfg(windows)]
        {
            use std::mem;
            use std::os::raw::c_void;
            use std::ptr;

            type DWORD = u32;
            type HANDLE = *mut c_void;
            type BOOL = i32;

            const STD_OUTPUT_HANDLE: DWORD = 0xFFFFFFF5;
            const ENABLE_VIRTUAL_TERMINAL_PROCESSING: DWORD = 0x0004;

            extern "system" {
                fn GetStdHandle(nStdHandle: DWORD) -> HANDLE;
                fn GetConsoleMode(hConsoleHandle: HANDLE, lpMode: *mut DWORD) -> BOOL;
                fn SetConsoleMode(hConsoleHandle: HANDLE, dwMode: DWORD) -> BOOL;
            }

            unsafe {
                let handle = GetStdHandle(STD_OUTPUT_HANDLE);
                if handle.is_null() {
                    return false;
                }

                let mut mode: DWORD = 0;
                if GetConsoleMode(handle, &mut mode) == 0 {
                    return false;
                }

                if SetConsoleMode(handle, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING) != 0 {
                    return true;
                }
                false
            }
        }
        #[cfg(not(windows))]
        {
            // Unix-like systems generally support ANSI
            true
        }
    }

    fn colors_enabled() -> bool {
        unsafe {
            INIT.call_once(|| {
                COLORS_ENABLED = init_colors();
            });
            COLORS_ENABLED
        }
    }

    pub fn reset() -> &'static str {
        if colors_enabled() { "\x1b[0m" } else { "" }
    }
    pub fn red() -> &'static str {
        if colors_enabled() { "\x1b[31m" } else { "" }
    }
    pub fn green() -> &'static str {
        if colors_enabled() { "\x1b[32m" } else { "" }
    }
    pub fn yellow() -> &'static str {
        if colors_enabled() { "\x1b[33m" } else { "" }
    }
    pub fn blue() -> &'static str {
        if colors_enabled() { "\x1b[34m" } else { "" }
    }
    pub fn magenta() -> &'static str {
        if colors_enabled() { "\x1b[35m" } else { "" }
    }
    pub fn cyan() -> &'static str {
        if colors_enabled() { "\x1b[36m" } else { "" }
    }
    pub fn white() -> &'static str {
        if colors_enabled() { "\x1b[37m" } else { "" }
    }
    pub fn bright_black() -> &'static str {
        if colors_enabled() { "\x1b[90m" } else { "" }
    }
    pub fn bright_red() -> &'static str {
        if colors_enabled() { "\x1b[91m" } else { "" }
    }
    pub fn bright_green() -> &'static str {
        if colors_enabled() { "\x1b[92m" } else { "" }
    }
    pub fn bright_yellow() -> &'static str {
        if colors_enabled() { "\x1b[93m" } else { "" }
    }
    pub fn bright_blue() -> &'static str {
        if colors_enabled() { "\x1b[94m" } else { "" }
    }
    pub fn bright_magenta() -> &'static str {
        if colors_enabled() { "\x1b[95m" } else { "" }
    }
    pub fn bright_cyan() -> &'static str {
        if colors_enabled() { "\x1b[96m" } else { "" }
    }
    pub fn bright_white() -> &'static str {
        if colors_enabled() { "\x1b[97m" } else { "" }
    }
    pub fn bg_red() -> &'static str {
        if colors_enabled() { "\x1b[41m" } else { "" }
    }
    pub fn bg_green() -> &'static str {
        if colors_enabled() { "\x1b[42m" } else { "" }
    }
    pub fn bg_yellow() -> &'static str {
        if colors_enabled() { "\x1b[43m" } else { "" }
    }
    pub fn bg_blue() -> &'static str {
        if colors_enabled() { "\x1b[44m" } else { "" }
    }
    pub fn bg_magenta() -> &'static str {
        if colors_enabled() { "\x1b[45m" } else { "" }
    }
    pub fn bg_cyan() -> &'static str {
        if colors_enabled() { "\x1b[46m" } else { "" }
    }
    pub fn bg_white() -> &'static str {
        if colors_enabled() { "\x1b[47m" } else { "" }
    }
    pub fn underl() -> &'static str {
        if colors_enabled() { "\x1b[4m" } else { "" }
    }
    pub fn blink() -> &'static str {
        if colors_enabled() { "\x1b[5m" } else { "" }
    }
    pub fn invert() -> &'static str {
        if colors_enabled() { "\x1b[7m" } else { "" }
    }
}

const EYF_V: f64 = 1.6;
const TAPE_SIZE: usize = 30000000;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("{}Usage:{} eyefuck <command> [file.eyf]", colors::red(), colors::reset());
        return;
    }

    let mode = &args[1];

    match mode.as_str() {
        "run" => {
            if args.len() < 3 {
                println!("{}Please specify a file to run.{}", colors::red(), colors::reset());
                return;
            }
            let file = &args[2];
            let code = match fs::read_to_string(file) {
                Ok(content) => content,
                Err(e) => {
                    eprintln!("Error reading file: {}", e);
                    return;
                }
            };
            run_interpreter(&code);
        }
        "build" => {
            if args.len() < 3 {
                println!("{}Please specify a file to build.{}", colors::red(), colors::reset());
                return;
            }
            let file = &args[2];
            let output_name = if args.len() > 3 { &args[3] } else { "output" };
            build_to_fasm(file, output_name);
        }
        "asm" | "-S" | "--s" | "-asm" | "--asm" | "--S" => {
            if args.len() < 4 {
                println!("{}Please specify input file and output assembly file.{}", colors::red(), colors::reset());
                println!("{}Usage:{} eyefuck asm <file.eyf> <output.asm>", colors::yellow(), colors::reset());
                return;
            }
            let input_file = &args[2];
            let output_file = &args[3];
            generate_asm_only(input_file, output_file);
        }
        "-i" | "--i" | "i" | "REPL" | "repl" | "-repl" | "--repl" | "--REPL" | "-REPL" => {
            repl();
        }
        "help" | "-help" | "-h" | "--h" | "--help" | "h" => {
            println!("{}Eyefuck HELP:{}", colors::cyan(), colors::reset());
            println!("{}  eyefuck run <file.eyf>{}  -> {}execute the Eyefuck file{}", colors::yellow(), colors::reset(), colors::green(), colors::reset());
            println!("{}  eyefuck build <file.eyf> [output]{} -> {}compile to executable{}", colors::yellow(), colors::reset(), colors::green(), colors::reset());
            println!("{}  eyefuck asm <file.eyf> <output.asm>{} -> {}generate assembly file{}", colors::yellow(), colors::reset(), colors::green(), colors::reset());
            println!("{}  eyefuck -i{}             -> {}interactive REPL mode{}", colors::yellow(), colors::reset(), colors::green(), colors::reset());
            println!("{}  eyefuck about{}          -> {}information about this interpreter{}", colors::yellow(), colors::reset(), colors::green(), colors::reset());
        }
        "about" => {
            println!("{}Eyefuck DEV 2025{}", colors::cyan(), colors::reset());
            println!("{}MIT license{} see LICENSE for more information", colors::green(), colors::reset());
            println!("Please help me motive by giving the repo a star");
            println!("{}github:{} github.com/bandikaaking", colors::blue(), colors::reset());
            println!("crafted with {}<3{} by {}@Bandikaaking{}", colors::red(), colors::reset(), colors::yellow(), colors::reset());
        }
        "version" | "--v" | "--version" | "-v" | "v" | "-version" | "ver" | "--ver" | "-ver" => {
            println!("{}Current {}eyefuck {}version: {}{}", colors::cyan(), colors::green(), colors::bright_cyan(), EYF_V, colors::reset());
        }
        "ov" | "--ov" | "-ov"  => {
            println!("{}{}Other eyefuck versions{}", colors::underl(), colors::bright_green(), colors::reset());
            println!("{}0.10 | 0.11 | 0.13 | 0.20 | 1.01 | 1.2 | 1.3 | 1.4 | 1.4.2 | 1.5{}", colors::bright_yellow(), colors::reset());
        }
        _ => {
            println!("{}Unknown {}mode:{} {}", colors::red(), colors::cyan(), colors::reset(), mode);
        }
    }
}

// ---------------------------
// Interactive REPL
// ---------------------------
fn repl() {
    println!("{}Eyefuck DEV 2025 - REPL{}", colors::cyan(), colors::reset());
    println!("Type commands below, empty line to execute, Ctrl+C to exit");
    
    let mut code_lines = Vec::new();
    
    loop {
        print!("> ");
        io::stdout().flush().unwrap();
        
        let mut line = String::new();
        match io::stdin().read_line(&mut line) {
            Ok(0) => break,
            Ok(_) => {
                let line = line.trim().to_string();
                if line.is_empty() {
                    run_interpreter(&code_lines.join("\n"));
                    code_lines.clear();
                    continue;
                }
                code_lines.push(line);
            }
            Err(e) => {
                eprintln!("Error reading input: {}", e);
                break;
            }
        }
    }
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
fn run_interpreter(code: &str) {
    let mut tape = vec![0u8; TAPE_SIZE];
    let mut ptr = 0;
    let lines: Vec<&str> = code.lines().collect();
    let mut loop_stack: Vec<usize> = Vec::new();
    let mut i = 0;

    while i < lines.len() {
        let mut line = lines[i].trim();

        // remove comments after #
        if let Some(comment_pos) = line.find('#') {
            line = &line[..comment_pos].trim();
        }

        if line.is_empty() {
            i += 1;
            continue;
        }

        match line {
            "^" => {
                tape[ptr] = tape[ptr].wrapping_add(1);
            }
            "v" => {
                tape[ptr] = tape[ptr].wrapping_sub(1);
            }
            ">" => {
                ptr = (ptr + 1) % TAPE_SIZE;
            }
            "<" => {
                ptr = if ptr == 0 { TAPE_SIZE - 1 } else { ptr - 1 };
            }
            "," => {
                let mut input = [0u8; 1];
                if let Ok(_) = io::stdin().read_exact(&mut input) {
                    tape[ptr] = input[0];
                }
            }
            "." => {
                print!("{}", tape[ptr] as char);
                io::stdout().flush().unwrap();
            }
            "loop[" => {
                loop_stack.push(i);
            }
            "]" => {
                if tape[ptr] != 0 {
                    if let Some(&loop_start) = loop_stack.last() {
                        i = loop_start;
                    } else {
                        eprintln!("Unmatched ]");
                        process::exit(1);
                    }
                } else {
                    loop_stack.pop();
                }
            }
            "reset" => {
                tape[ptr] = 0;
            }
            _ if line.starts_with("print \"") && line.ends_with('\"') => {
                let content = &line[7..line.len()-1];
                print!("{}", content);
                io::stdout().flush().unwrap();
            }
            _ if line.starts_with("jump[") && line.ends_with(']') => {
                let jump_str = &line[5..line.len()-1];
                if let Ok(jump_pos) = jump_str.parse::<usize>() {
                    if jump_pos >= TAPE_SIZE {
                        println!("{}Warning: Jump position {} exceeds tape size {}{}", colors::yellow(), jump_pos, TAPE_SIZE, colors::reset());
                    } else {
                        ptr = jump_pos;
                    }
                } else {
                    eprintln!("{}Invalid jump position: {}{}", colors::red(), jump_str, colors::reset());
                }
            }
            _ if line.starts_with("bin") => {
                let bin = line[3..].trim();
                match u8::from_str_radix(bin, 2) {
                    Ok(val) => tape[ptr] = val,
                    Err(_) => {
                        eprintln!("{}Invalid binary: {}{}", colors::red(), bin, colors::reset());
                        process::exit(1);
                    }
                }
            }
            _ if line.starts_with("col[") && line.ends_with(']') => {
                let hex = &line[4..line.len()-1];
                match u32::from_str_radix(hex, 16) {
                    Ok(color_int) => {
                        let r = (color_int >> 16) & 0xFF;
                        let g = (color_int >> 8) & 0xFF;
                        let b = color_int & 0xFF;
                        print!("\x1b[38;2;{};{};{}m", r, g, b);
                    }
                    Err(_) => {
                        eprintln!("{}Invalid HEX color: {}{}", colors::red(), hex, colors::reset());
                    }
                }
            }
            _ if line.starts_with("load[") && line.ends_with(']') => {
                let filename = &line[5..line.len()-1];
                match fs::read(filename) {
                    Ok(_) => tape[ptr] = 0,
                    Err(e) => {
                        eprintln!("{}Error loading file: {}{}", colors::red(), e, colors::reset());
                    }
                }
            }
            _ => {
                eprintln!("{}error caught while parsing{}", colors::red(), colors::reset());
                eprintln!("{}at line: {}{}", colors::red(), line, colors::reset());
                process::exit(1);
            }
        }
        i += 1;
    }
    // Reset colors at the end
    print!("{}", colors::reset());
    println!();
}

// ---------------------------
// FASM Compiler
// ---------------------------
fn build_to_fasm(filename: &str, output_name: &str) {
    println!("{}Compiling {} to FASM assembly...{}", colors::cyan(), filename, colors::reset());
    
    let code = match fs::read_to_string(filename) {
        Ok(content) => content,
        Err(e) => {
            eprintln!("Error reading file: {}", e);
            return;
        }
    };

    let fasm_code = generate_fasm(&code, output_name);
    
    let asm_filename = format!("{}.asm", output_name);
    match fs::write(&asm_filename, fasm_code) {
        Ok(_) => println!("{}FASM assembly written to {}{}", colors::green(), asm_filename, colors::reset()),
        Err(e) => {
            eprintln!("Error writing assembly file: {}", e);
            return;
        }
    }

    // Compile with FASM
    compile_with_fasm(&asm_filename, output_name);
}

fn generate_fasm(code: &str, output_name: &str) -> String {
    let mut fasm = String::new();
    
    // Simple FASM syntax that works
    if cfg!(target_os = "windows") {
        fasm.push_str("format PE64 console\n");
        fasm.push_str("entry start\n\n");
        
        // Use the simpler import syntax that FASM understands
        fasm.push_str("section '.idata' import data readable writeable\n");
        fasm.push_str("dd 0,0,0,RVA kernel32_name,RVA kernel32_table\n");
        fasm.push_str("dd 0,0,0,RVA msvcrt_name,RVA msvcrt_table\n");
        fasm.push_str("dd 0,0,0,0,0\n\n");
        //still not working? Why the fuck does not work??
        fasm.push_str("kernel32_table:\n");
        fasm.push_str("  ExitProcess dq RVA _ExitProcess\n");
        fasm.push_str("  GetStdHandle dq RVA _GetStdHandle\n");
        fasm.push_str("  WriteConsoleA dq RVA _WriteConsoleA\n");
        fasm.push_str("  ReadConsoleA dq RVA _ReadConsoleA\n");
        fasm.push_str("  GetProcessHeap dq RVA _GetProcessHeap\n");
        fasm.push_str("  HeapAlloc dq RVA _HeapAlloc\n");
        fasm.push_str("  HeapFree dq RVA _HeapFree\n");
        fasm.push_str("  dq 0\n\n");
        
        fasm.push_str("msvcrt_table:\n");
        fasm.push_str("  printf dq RVA _printf\n");
        fasm.push_str("  getchar dq RVA _getchar\n");
        fasm.push_str("  dq 0\n\n");
        
        fasm.push_str("kernel32_name db 'KERNEL32.DLL',0\n");
        fasm.push_str("msvcrt_name db 'MSVCRT.DLL',0\n\n");
        
        fasm.push_str("_ExitProcess dw 0\n");
        fasm.push_str("  db 'ExitProcess',0\n");
        fasm.push_str("_GetStdHandle dw 0\n");
        fasm.push_str("  db 'GetStdHandle',0\n");
        fasm.push_str("_WriteConsoleA dw 0\n");
        fasm.push_str("  db 'WriteConsoleA',0\n");
        fasm.push_str("_ReadConsoleA dw 0\n");
        fasm.push_str("  db 'ReadConsoleA',0\n");
        fasm.push_str("_GetProcessHeap dw 0\n");
        fasm.push_str("  db 'GetProcessHeap',0\n");
        fasm.push_str("_HeapAlloc dw 0\n");
        fasm.push_str("  db 'HeapAlloc',0\n");
        fasm.push_str("_HeapFree dw 0\n");
        fasm.push_str("  db 'HeapFree',0\n");
        fasm.push_str("_printf dw 0\n");
        fasm.push_str("  db 'printf',0\n");
        fasm.push_str("_getchar dw 0\n");
        fasm.push_str("  db '_fgetchar',0\n\n");
    } else {
        fasm.push_str("format ELF64 executable\n");
        fasm.push_str("entry start\n\n");
        
        fasm.push_str("segment readable executable\n");
    }
    
    fasm.push_str("section '.text' code readable executable\n");
    
    fasm.push_str("start:\n");
    
    if cfg!(target_os = "windows") {
        fasm.push_str("    sub rsp, 40\n");
        fasm.push_str("    call [GetProcessHeap]\n");
        fasm.push_str("    mov rcx, rax\n");
        fasm.push_str("    mov rdx, 8\n");
        fasm.push_str("    mov r8, 30000000\n");
        fasm.push_str("    call [HeapAlloc]\n");
        fasm.push_str("    add rsp, 40\n");
        fasm.push_str("    mov [tape_ptr], rax\n");
        fasm.push_str("    test rax, rax\n");
        fasm.push_str("    jz .exit_failure\n");
    } else {
        fasm.push_str("    mov rax, 9\n");
        fasm.push_str("    xor rdi, rdi\n");
        fasm.push_str("    mov rsi, 30000000\n");
        fasm.push_str("    mov rdx, 3\n");
        fasm.push_str("    mov r10, 34\n");
        fasm.push_str("    mov r8, -1\n");
        fasm.push_str("    xor r9, r9\n");
        fasm.push_str("    syscall\n");
        fasm.push_str("    mov [tape_ptr], rax\n");
        fasm.push_str("    cmp rax, -1\n");
        fasm.push_str("    je .exit_failure\n");
    }
    
    fasm.push_str("    mov dword [ptr], 0\n\n");
    
    let lines: Vec<&str> = code.lines().collect();
    let mut label_counter = 0;
    let mut loop_stack: Vec<usize> = Vec::new();
    
    for (i, line) in lines.iter().enumerate() {
        let mut clean_line = line.trim();
        
        if let Some(comment_pos) = clean_line.find('#') {
            clean_line = &clean_line[..comment_pos].trim();
        }
        
        if clean_line.is_empty() {
            continue;
        }
        
        match clean_line {
            "^" => {
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    inc byte [rax + rcx]\n");
            }
            "v" => {
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    dec byte [rax + rcx]\n");
            }
            ">" => {
                fasm.push_str("    inc dword [ptr]\n");
                fasm.push_str("    cmp dword [ptr], 30000000\n");
                fasm.push_str("    jl .no_wrap_right\n");
                fasm.push_str("    mov dword [ptr], 0\n");
                fasm.push_str(".no_wrap_right:\n");
            }
            "<" => {
                fasm.push_str("    cmp dword [ptr], 0\n");
                fasm.push_str("    jg .no_wrap_left\n");
                fasm.push_str("    mov dword [ptr], 29999999\n");
                fasm.push_str("    jmp .wrap_done_left\n");
                fasm.push_str(".no_wrap_left:\n");
                fasm.push_str("    dec dword [ptr]\n");
                fasm.push_str(".wrap_done_left:\n");
            }
            "." => {
                if cfg!(target_os = "windows") {
                    fasm.push_str("    sub rsp, 40\n");
                    fasm.push_str("    mov rax, [tape_ptr]\n");
                    fasm.push_str("    mov ecx, [ptr]\n");
                    fasm.push_str("    movzx rcx, byte [rax + rcx]\n");
                    fasm.push_str("    mov [output_buffer], cl\n");
                    fasm.push_str("    lea rcx, [output_buffer]\n");
                    fasm.push_str("    call [printf]\n");
                    fasm.push_str("    add rsp, 40\n");
                } else {
                    fasm.push_str("    mov rax, 1\n");
                    fasm.push_str("    mov rdi, 1\n");
                    fasm.push_str("    mov rsi, [tape_ptr]\n");
                    fasm.push_str("    mov edx, [ptr]\n");
                    fasm.push_str("    add rsi, rdx\n");
                    fasm.push_str("    mov rdx, 1\n");
                    fasm.push_str("    syscall\n");
                }
            }
            "," => {
                if cfg!(target_os = "windows") {
                    fasm.push_str("    sub rsp, 40\n");
                    fasm.push_str("    call [getchar]\n");
                    fasm.push_str("    add rsp, 40\n");
                    fasm.push_str("    mov rbx, [tape_ptr]\n");
                    fasm.push_str("    mov ecx, [ptr]\n");
                    fasm.push_str("    mov [rbx + rcx], al\n");
                } else {
                    fasm.push_str("    mov rax, 0\n");
                    fasm.push_str("    mov rdi, 0\n");
                    fasm.push_str("    mov rsi, [tape_ptr]\n");
                    fasm.push_str("    mov edx, [ptr]\n");
                    fasm.push_str("    add rsi, rdx\n");
                    fasm.push_str("    mov rdx, 1\n");
                    fasm.push_str("    syscall\n");
                }
            }
            "reset" => {
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    mov byte [rax + rcx], 0\n");
            }
            "loop[" => {
                let label = format!("loop_{}", label_counter);
                fasm.push_str(&format!("{}:\n", label));
                fasm.push_str("    mov rax, [tape_ptr]\n");
                fasm.push_str("    mov ecx, [ptr]\n");
                fasm.push_str("    cmp byte [rax + rcx], 0\n");
                fasm.push_str(&format!("    je end_loop_{}\n", label_counter));
                loop_stack.push(label_counter);
                label_counter += 1;
            }
            "]" => {
                if let Some(loop_id) = loop_stack.pop() {
                    fasm.push_str("    mov rax, [tape_ptr]\n");
                    fasm.push_str("    mov ecx, [ptr]\n");
                    fasm.push_str("    cmp byte [rax + rcx], 0\n");
                    fasm.push_str(&format!("    jne loop_{}\n", loop_id));
                    fasm.push_str(&format!("end_loop_{}:\n", loop_id));
                }
            }
            line if line.starts_with("print \"") && line.ends_with('\"') => {
                let content = &line[7..line.len()-1];
                let label = format!("print_str_{}", label_counter);
                label_counter += 1;
                
                fasm.push_str(&format!("    jmp .after_{}\n", label));
                fasm.push_str(&format!(".{} db \"{}\", 0\n", label, content));
                fasm.push_str(&format!(".after_{}:\n", label));
                
                if cfg!(target_os = "windows") {
                    fasm.push_str("    sub rsp, 40\n");
                    fasm.push_str(&format!("    lea rcx, [.{}]\n", label));
                    fasm.push_str("    call [printf]\n");
                    fasm.push_str("    add rsp, 40\n");
                } else {
                    fasm.push_str("    mov rax, 1\n");
                    fasm.push_str("    mov rdi, 1\n");
                    fasm.push_str(&format!("    lea rsi, [.{}]\n", label));
                    fasm.push_str(&format!("    mov rdx, {}\n", content.len()));
                    fasm.push_str("    syscall\n");
                }
            }
            line if line.starts_with("jump[") && line.ends_with(']') => {
                let jump_str = &line[5..line.len()-1];
                if let Ok(jump_pos) = jump_str.parse::<usize>() {
                    fasm.push_str(&format!("    mov dword [ptr], {}\n", jump_pos));
                }
            }
            line if line.starts_with("bin") => {
                let bin = line[3..].trim();
                if let Ok(val) = u8::from_str_radix(bin, 2) {
                    fasm.push_str("    mov rax, [tape_ptr]\n");
                    fasm.push_str("    mov ecx, [ptr]\n");
                    fasm.push_str(&format!("    mov byte [rax + rcx], {}\n", val));
                }
            }
            _ => {
                // Skip unknown commands
                fasm.push_str(&format!("    ; Unknown: {}\n", clean_line));
            }
        }
        fasm.push_str("\n");
    }
    
    // Cleanup
    if cfg!(target_os = "windows") {
        fasm.push_str("    sub rsp, 40\n");
        fasm.push_str("    call [GetProcessHeap]\n");
        fasm.push_str("    mov rcx, rax\n");
        fasm.push_str("    mov rdx, 0\n");
        fasm.push_str("    mov r8, [tape_ptr]\n");
        fasm.push_str("    call [HeapFree]\n");
        fasm.push_str("    add rsp, 40\n");
        fasm.push_str("    xor ecx, ecx\n");
        fasm.push_str("    call [ExitProcess]\n");
    } else {
        fasm.push_str("    mov rax, 60\n");
        fasm.push_str("    xor rdi, rdi\n");
        fasm.push_str("    syscall\n");
    }
    
    fasm.push_str("\n.exit_failure:\n");
    if cfg!(target_os = "windows") {
        fasm.push_str("    mov ecx, 1\n");
        fasm.push_str("    call [ExitProcess]\n");
    } else {
        fasm.push_str("    mov rax, 60\n");
        fasm.push_str("    mov rdi, 1\n");
        fasm.push_str("    syscall\n");
    }
    
    // Data section
    fasm.push_str("\nsection '.data' data readable writeable\n");
    fasm.push_str("tape_ptr dq 0\n");
    fasm.push_str("ptr dd 0\n");
    fasm.push_str("output_buffer db 0\n");
    
    fasm
}

fn generate_asm_only(input_file: &str, output_file: &str) {
    println!("{}Generating assembly for {}...{}", colors::cyan(), input_file, colors::reset());
    
    let code = match fs::read_to_string(input_file) {
        Ok(content) => content,
        Err(e) => {
            eprintln!("Error reading file: {}", e);
            return;
        }
    };

    let fasm_code = generate_fasm(&code, "output");
    
    match fs::write(output_file, fasm_code) {
        Ok(_) => println!("{}Assembly written to {}{}", colors::green(), output_file, colors::reset()),
        Err(e) => {
            eprintln!("Error writing assembly file: {}", e);
            return;
        }
    }
}

fn compile_with_fasm(asm_filename: &str, output_name: &str) {
    println!("{}Assembling with FASM...{}", colors::yellow(), colors::reset());
    
    let output_file = if cfg!(target_os = "windows") {
        format!("{}.exe", output_name)
    } else {
        output_name.to_string()
    };
    
    let status = process::Command::new("fasm")
        .arg(asm_filename)
        .arg(&output_file)
        .status();
    
    match status {
        Ok(exit_status) if exit_status.success() => {
            println!("{}Success! Compiled to: {}{}", colors::green(), output_file, colors::reset());
            
            // Clean up intermediate .asm file
            let _ = fs::remove_file(asm_filename);
            println!("{}Cleaned up intermediate files{}", colors::bright_black(), colors::reset());
        }
        Ok(exit_status) => {
            eprintln!("{}FASM compilation failed with exit code: {}{}", colors::red(), exit_status, colors::reset());
            eprintln!("{}Please make sure FASM is installed and in your PATH{}", colors::yellow(), colors::reset());
            
            // Show the assembly file location for debugging
            println!("{}Assembly file saved at: {}{}", colors::yellow(), asm_filename, colors::reset());
        }
        Err(e) => {
            eprintln!("{}Failed to run FASM: {}{}", colors::red(), e, colors::reset());
            eprintln!("{}Install FASM from: https://flatassembler.net/{}", colors::yellow(), colors::reset());
        }
    }
}

/* why am i doing this.... but now it's a compiler! */

/* 
Now you can do:
eyefuck build hello.eyf hello
And it will generate hello.exe (or hello on Linux)

The .asm file is automatically cleaned up after compilation
Uses appropriate memory allocation for Windows/Linux
*/