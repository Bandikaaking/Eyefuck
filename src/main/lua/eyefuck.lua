--[[
Eyefuck.lua as i was saying in the eyefuck.rb i will **NOT** compile this
, go to eyefuck.rb for more info 
]]

-- ANSI colors
local RESET = "\27[0m"
local RED = "\27[31m"
local GREEN = "\27[32m"
local YELLOW = "\27[33m"
local BLUE = "\27[34m"
local CYAN = "\27[36m"
local WHITE = "\27[97m"

local EYF_V = 1.2
local TAPE_SIZE = 300000

local function main()
    if #arg < 1 then
        print(RED .. "Usage:" .. RESET .. " eyefuck <command> [file.eyf]")
        return
    end

    local mode = arg[1]

    if mode == "run" then
        if #arg < 2 then
            print(RED .. "Please specify a file to run." .. RESET)
            return
        end
        local file = arg[2]
        local f = io.open(file, "r")
        if not f then
            print("Error reading file")
            return
        end
        local code = f:read("*a")
        f:close()
        run_interpreter(code)
    elseif mode == "-i" or mode == "--i" or mode == "i" then
        start_repl()
    elseif mode == "help" or mode == "-help" or mode == "-h" or mode == "--h" or mode == "--help" then
        print(CYAN .. "Eyefuck HELP:" .. RESET)
        print(YELLOW .. "  eyefuck run <file.eyf>" .. RESET .. "  -> " .. GREEN .. "execute the Eyefuck file" .. RESET)
        print(YELLOW .. "  eyefuck -i" .. RESET .. "             -> " .. GREEN .. "interactive REPL mode" .. RESET)
        print(YELLOW .. "  eyefuck about" .. RESET .. "          -> " .. GREEN .. "information about this interpreter" .. RESET)
    elseif mode == "about" then
        print(CYAN .. "Eyefuck DEV 2025" .. RESET)
        print(GREEN .. "MIT license" .. RESET .. " see LICENSE for more information")
        print("Please help me motive by giving the repo a star")
        print(BLUE .. "github:" .. RESET .. " github.com/bandikaaking")
        print("crafted with " .. RED .. "<3" .. RESET .. " by " .. YELLOW .. "@Bandikaaking" .. RESET)
    elseif mode == "version" or mode == "--v" or mode == "--version" or mode == "-v" or mode == "v" or mode == "-version" then
        print("Current eyefuck version: " .. EYF_V)
    elseif mode == "ov" or mode == "-ov" or mode == "--ov" then
        print("Other Eyefuck versions: ")
        print("0.10: Started / added 2 instructions")
        print("0.11-0.43: Fixed many bugs, and edded 5 more instructions")
        print("1.0: Added syntax highliting")
        print("1.1: Fixed bugs")
        print("added more eyefuck modes / rewrited README.md")
    else
        print(RED .. "Unknown mode:" .. RESET .. " " .. mode)
    end
end

-- ---------------------------
-- Interactive REPL
-- ---------------------------
local function start_repl()
    print(CYAN .. "Eyefuck DEV 2025 - REPL" .. RESET)
    print("Type commands below, empty line to execute, Ctrl+C to exit")
    
    local code_lines = {}
    
    while true do
        io.write("$ ")
        io.flush()
        local line = io.read()
        
        if not line or line == "" then
            run_interpreter(table.concat(code_lines, "\n"))
            code_lines = {}
        else
            table.insert(code_lines, line)
        end
    end
end

-- ---------------------------
-- Eyefuck Interpreter
-- ---------------------------
local function run_interpreter(code)
    local tape = {}
    for i = 1, TAPE_SIZE do
        tape[i] = 0
    end
    local ptr = 1  -- Lua uses 1-based indexing
    local lines = {}
    for line in code:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    local loop_stack = {}
    local i = 1

    while i <= #lines do
        local line = lines[i]:match("^%s*(.-)%s*$")  -- trim
        
        -- remove comments after #
        local comment_pos = line:find("#")
        if comment_pos then
            line = line:sub(1, comment_pos - 1):match("^%s*(.-)%s*$") or ""
        end
        
        if line == "" then
            i = i + 1
            goto continue
        end

        if line == "^" then
            -- increment cell
            tape[ptr] = (tape[ptr] + 1) % 256
        elseif line == "v" then
            -- decrement cell
            tape[ptr] = (tape[ptr] - 1) % 256
        elseif line == ">" then
            -- move pointer right
            ptr = (ptr % TAPE_SIZE) + 1
        elseif line == "<" then
            -- move pointer left
            ptr = ptr == 1 and TAPE_SIZE or ptr - 1
        elseif line:sub(1, 3) == "bin" then
            -- set cell from binary
            local bin = line:sub(4):match("^%s*(.-)%s*$")
            local success, val = pcall(function()
                return tonumber(bin, 2)
            end)
            if success and val then
                tape[ptr] = math.floor(val) % 256
            else
                print("Invalid binary format")
                return
            end
        elseif line:sub(1, 3) == "col" then
            -- set text color from HEX
            local start_idx = line:find("%[")
            local end_idx = line:find("%]")
            if start_idx and end_idx and end_idx > start_idx + 1 then
                local hex = line:sub(start_idx + 1, end_idx - 1)
                local success, color_int = pcall(function()
                    return tonumber(hex, 16)
                end)
                if success and color_int then
                    local r = math.floor(color_int / 65536) % 256
                    local g = math.floor(color_int / 256) % 256
                    local b = color_int % 256
                    io.write(string.format("\27[38;2;%d;%d;%dm", r, g, b))
                else
                    print("Invalid HEX color")
                    return
                end
            end
        elseif line:sub(1, 5) == "load[" then
            -- load file
            local start_idx = line:find("%[")
            local end_idx = line:find("%]")
            if start_idx and end_idx and end_idx > start_idx + 1 then
                local filename = line:sub(start_idx + 1, end_idx - 1)
                local f = io.open(filename, "r")
                if f then
                    f:close()
                    tape[ptr] = 0
                else
                    print("Error loading file")
                    return
                end
            end
        elseif line == "," then
            -- read single byte input
            local input = io.read(1)
            if input then
                tape[ptr] = string.byte(input)
            end
        elseif line == "." then
            -- print cell as char
            io.write(string.char(tape[ptr]))
        elseif line == "loop[" then
            -- start loop
            table.insert(loop_stack, i)
        elseif line == "]" then
            -- end loop
            if tape[ptr] ~= 0 then
                if #loop_stack == 0 then
                    print("Unmatched ]")
                    return
                end
                i = loop_stack[#loop_stack]
            else
                if #loop_stack > 0 then
                    table.remove(loop_stack)
                end
            end
        else
            print(RED .. "error caught while parsing")
            print(RED .. "at line: " .. line)
            return
        end
        
        i = i + 1
        ::continue::
    end
    print()
end

-- Run main if this file is executed directly
if arg then
    main()
end
--good job Andrew i guess