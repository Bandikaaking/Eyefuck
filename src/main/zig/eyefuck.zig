// They say "zig is easy" i.. have no idea WHO lied to them?!

const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const io = std.io;
const process = std.process;
const fmt = std.fmt;
const heap = std.heap;

// ANSI colors
const RESET = "\x1b[0m";
const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const BLUE = "\x1b[34m";
const CYAN = "\x1b[36m";
const WHITE = "\x1b[97m";

const EYF_V: f32 = 1.2;
const TAPE_SIZE: usize = 300000;

// ---------------------------
// Main function
// ---------------------------
pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print(RED ++ "Usage:" ++ RESET ++ " eyefuck <command> [file.eyf]\n", .{});
        return;
    }

    const mode = args[1];

    if (mem.eql(u8, mode, "run")) {
        if (args.len < 3) {
            std.debug.print(RED ++ "Please specify a file to run." ++ RESET ++ "\n", .{});
            return;
        }
        const file = args[2];
        const code = try fs.cwd().readFileAlloc(allocator, file, 10 * 1024 * 1024);
        defer allocator.free(code);
        try runInterpreter(allocator, code);
    } else if (mem.eql(u8, mode, "-i") or mem.eql(u8, mode, "--i") or mem.eql(u8, mode, "i")) {
        try startREPL(allocator);
    } else if (mem.eql(u8, mode, "help") or mem.eql(u8, mode, "-help") or 
               mem.eql(u8, mode, "-h") or mem.eql(u8, mode, "--h") or mem.eql(u8, mode, "--help")) {
        std.debug.print(CYAN ++ "Eyefuck HELP:" ++ RESET ++ "\n", .{});
        std.debug.print(YELLOW ++ "  eyefuck run <file.eyf>" ++ RESET ++ "  -> " ++ GREEN ++ "execute the Eyefuck file" ++ RESET ++ "\n", .{});
        std.debug.print(YELLOW ++ "  eyefuck -i" ++ RESET ++ "             -> " ++ GREEN ++ "interactive REPL mode" ++ RESET ++ "\n", .{});
        std.debug.print(YELLOW ++ "  eyefuck about" ++ RESET ++ "          -> " ++ GREEN ++ "information about this interpreter" ++ RESET ++ "\n", .{});
    } else if (mem.eql(u8, mode, "about")) {
        std.debug.print(CYAN ++ "Eyefuck DEV 2025" ++ RESET ++ "\n", .{});
        std.debug.print(GREEN ++ "MIT license" ++ RESET ++ " see LICENSE for more information\n", .{});
        std.debug.print("Please help me motive by giving the repo a star\n", .{});
        std.debug.print(BLUE ++ "github:" ++ RESET ++ " github.com/bandikaaking\n", .{});
        std.debug.print("crafted with " ++ RED ++ "<3" ++ RESET ++ " by " ++ YELLOW ++ "@Bandikaaking" ++ RESET ++ "\n", .{});
    } else if (mem.eql(u8, mode, "version") or mem.eql(u8, mode, "--v") or 
               mem.eql(u8, mode, "--version") or mem.eql(u8, mode, "-v") or 
               mem.eql(u8, mode, "v") or mem.eql(u8, mode, "-version")) {
        std.debug.print("Current eyefuck version: {d}\n", .{EYF_V});
    } else if (mem.eql(u8, mode, "ov") or mem.eql(u8, mode, "-ov") or mem.eql(u8, mode, "--ov")) {
        std.debug.print("Other Eyefuck versions: \n", .{});
        std.debug.print("0.10: Started / added 2 instructions\n", .{});
        std.debug.print("0.11-0.43: Fixed many bugs, and edded 5 more instructions\n", .{});
        std.debug.print("1.0: Added syntax highliting\n", .{});
        std.debug.print("1.1: Fixed bugs\n", .{});
        std.debug.print("added more eyefuck modes / rewrited README.md\n", .{});
    } else {
        std.debug.print(RED ++ "Unknown mode:" ++ RESET ++ " {s}\n", .{mode});
    }
}

// ---------------------------
// Interactive REPL
// ---------------------------
fn startREPL(allocator: std.mem.Allocator) !void {
    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn().reader();

    try stdout.print(CYAN ++ "Eyefuck DEV 2025 - REPL" ++ RESET ++ "\n", .{});
    try stdout.print("Type commands below, empty line to execute, Ctrl+C to exit\n", .{});

    var code_lines = std.ArrayList(u8).init(allocator);
    defer code_lines.deinit();

    while (true) {
        try stdout.print("$ ", .{});
        
        var buffer: [256]u8 = undefined;
        const line = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
        
        if (line == null or line.?.len == 0) {
            try runInterpreter(allocator, code_lines.items);
            code_lines.clearRetainingCapacity();
            continue;
        }
        
        try code_lines.appendSlice(line.?);
        try code_lines.append('\n');
    }
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
fn runInterpreter(allocator: std.mem.Allocator, code: []const u8) !void {
    var tape = try allocator.alloc(u8, TAPE_SIZE);
    defer allocator.free(tape);
    @memset(tape, 0);

    var ptr: usize = 0;
    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iter = mem.splitSequence(u8, code, "\n");
    while (iter.next()) |line| {
        try lines.append(line);
    }

    var loop_stack = std.ArrayList(usize).init(allocator);
    defer loop_stack.deinit();

    var i: usize = 0;
    while (i < lines.items.len) : (i += 1) {
        var line = mem.trim(u8, lines.items[i], " \t\r");
        
        // remove comments after #
        if (mem.indexOf(u8, line, "#")) |comment_pos| {
            line = line[0..comment_pos];
            line = mem.trim(u8, line, " \t");
        }
        
        if (line.len == 0) continue;

        if (mem.eql(u8, line, "^")) {
            // increment cell
            tape[ptr] +%= 1;
        } else if (mem.eql(u8, line, "v")) {
            // decrement cell
            tape[ptr] -%= 1;
        } else if (mem.eql(u8, line, ">")) {
            // move pointer right
            ptr = (ptr + 1) % TAPE_SIZE;
        } else if (mem.eql(u8, line, "<")) {
            // move pointer left
            ptr = if (ptr == 0) TAPE_SIZE - 1 else ptr - 1;
        } else if (mem.startsWith(u8, line, "bin")) {
            // set cell from binary
            const bin_str = mem.trim(u8, line[3..], " \t");
            tape[ptr] = try fmt.parseUnsigned(u8, bin_str, 2);
        } else if (mem.startsWith(u8, line, "col")) {
            // set text color from HEX
            const start = mem.indexOf(u8, line, "[");
            const end = mem.indexOf(u8, line, "]");
            if (start != null and end != null and end.? > start.? + 1) {
                const hex = line[start.? + 1 .. end.?];
                const color_int = try fmt.parseUnsigned(u32, hex, 16);
                const r = (color_int >> 16) & 0xFF;
                const g = (color_int >> 8) & 0xFF;
                const b = color_int & 0xFF;
                const stdout = io.getStdOut().writer();
                try stdout.print("\x1b[38;2;{d};{d};{d}m", .{r, g, b});
            }
        } else if (mem.startsWith(u8, line, "load[")) {
            // load file
            const start = mem.indexOf(u8, line, "[");
            const end = mem.indexOf(u8, line, "]");
            if (start != null and end != null and end.? > start.? + 1) {
                const filename = line[start.? + 1 .. end.?];
                _ = try fs.cwd().openFile(filename, .{});
                tape[ptr] = 0;
            }
        } else if (mem.eql(u8, line, ",")) {
            // read single byte input
            const stdin = io.getStdIn().reader();
            tape[ptr] = try stdin.readByte();
        } else if (mem.eql(u8, line, ".")) {
            // print cell as char
            const stdout = io.getStdOut().writer();
            try stdout.print("{c}", .{tape[ptr]});
        } else if (mem.eql(u8, line, "loop[")) {
            // start loop
            try loop_stack.append(i);
        } else if (mem.eql(u8, line, "]")) {
            // end loop
            if (tape[ptr] != 0) {
                if (loop_stack.items.len > 0) {
                    i = loop_stack.items[loop_stack.items.len - 1];
                } else {
                    std.debug.print("Unmatched ]\n", .{});
                    return;
                }
            } else {
                if (loop_stack.items.len > 0) {
                    _ = loop_stack.pop();
                }
            }
        } else {
            std.debug.print(RED ++ "error caught while parsing\n", .{});
            std.debug.print(RED ++ "at line: {s}\n", .{line});
            return;
        }
    }

    const stdout = io.getStdOut().writer();
    try stdout.print("\n", .{});
}
//good job Andrew i guess