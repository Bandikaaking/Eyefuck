# ruby eyefuck interpreter, WOAH
# ruby is interpreter andd not a compiled... i.. i will search if i can get a eyefuck.exe orrr ... wait why do i need it??
# there is already a eyefuck.exe (or eyefuck.o linux / UNIX users) when the eyefuck.go is compiled... WAIIIIITTTTT
# welp then, there will be no build file for c# rust lua ruby, only for go (now it is only rust)
# (sorry for this)


# ANSI colors
RESET = "\033[0m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
CYAN = "\033[36m"
WHITE = "\033[97m"

EYF_V = 1.2
TAPE_SIZE = 300000

def main
  if ARGV.length < 1
    puts "#{RED}Usage:#{RESET} eyefuck <command> [file.eyf]"
    return
  end

  mode = ARGV[0]

  case mode
  when "run"
    if ARGV.length < 2
      puts "#{RED}Please specify a file to run.#{RESET}"
      return
    end
    file = ARGV[1]
    begin
      code = File.read(file)
      run_interpreter(code)
    rescue => e
      puts "Error reading file: #{e.message}"
    end
  when "-i", "--i", "i"
    start_repl
  when "help", "-help", "-h", "--h", "--help"
    puts "#{CYAN}Eyefuck HELP:#{RESET}"
    puts "#{YELLOW}  eyefuck run <file.eyf>#{RESET}  -> #{GREEN}execute the Eyefuck file#{RESET}"
    puts "#{YELLOW}  eyefuck -i#{RESET}             -> #{GREEN}interactive REPL mode#{RESET}"
    puts "#{YELLOW}  eyefuck about#{RESET}          -> #{GREEN}information about this interpreter#{RESET}"
  when "about"
    puts "#{CYAN}Eyefuck DEV 2025#{RESET}"
    puts "#{GREEN}MIT license#{RESET} see LICENSE for more information"
    puts "Please help me motive by giving the repo a star"
    puts "#{BLUE}github:#{RESET} github.com/bandikaaking"
    puts "crafted with #{RED}<3#{RESET} by #{YELLOW}@Bandikaaking#{RESET}"
  when "version", "--v", "--version", "-v", "v", "-version"
    puts "Current eyefuck version: #{EYF_V}"
  when "ov", "-ov", "--ov"
    puts "Other Eyefuck versions: "
    puts "0.10: Started / added 2 instructions"
    puts "0.11-0.43: Fixed many bugs, and edded 5 more instructions"
    puts "1.0: Added syntax highliting"
    puts "1.1: Fixed bugs"
    puts "added more eyefuck modes / rewrited README.md"
  else
    puts "#{RED}Unknown mode:#{RESET} #{mode}"
  end
end

# ---------------------------
# Interactive REPL
# ---------------------------
def start_repl
  puts "#{CYAN}Eyefuck DEV 2025 - REPL#{RESET}"
  puts "Type commands below, empty line to execute, Ctrl+C to exit"
  
  code_lines = []
  
  loop do
    print "$ "
    line = gets&.chomp
    
    if line.nil? || line.empty?
      run_interpreter(code_lines.join("\n"))
      code_lines.clear
      next
    end
    
    code_lines << line
  end
end

# ---------------------------
# Eyefuck Interpreter
# ---------------------------
def run_interpreter(code)
  tape = Array.new(TAPE_SIZE, 0)
  ptr = 0
  lines = code.split("\n")
  loop_stack = []
  i = 0

  while i < lines.length
    line = lines[i].strip
    
    # remove comments after #
    if line.include?('#')
      line = line.split('#')[0].strip
    end
    
    next if line.empty?

    case line
    when "^" # increment cell
      tape[ptr] = (tape[ptr] + 1) % 256
    when "v" # decrement cell
      tape[ptr] = (tape[ptr] - 1) % 256
    when ">" # move pointer right
      ptr = (ptr + 1) % TAPE_SIZE
    when "<" # move pointer left
      ptr = ptr == 0 ? TAPE_SIZE - 1 : ptr - 1
    when /^bin/ # set cell from binary
      bin = line[3..-1].strip
      begin
        tape[ptr] = bin.to_i(2)
      rescue
        puts "Invalid binary format"
        return
      end
    when /^col/ # set text color from HEX
      if line.include?('[') && line.include?(']')
        start_idx = line.index('[')
        end_idx = line.index(']')
        if end_idx > start_idx + 1
          hex = line[start_idx+1...end_idx]
          begin
            color_int = hex.to_i(16)
            r = (color_int >> 16) & 0xFF
            g = (color_int >> 8) & 0xFF
            b = color_int & 0xFF
            print "\033[38;2;#{r};#{g};#{b}m"
          rescue
            puts "Invalid HEX color"
            return
          end
        end
      end
    when /^load\[/ # load file
      if line.include?('[') && line.include?(']')
        start_idx = line.index('[')
        end_idx = line.index(']')
        if end_idx > start_idx + 1
          filename = line[start_idx+1...end_idx]
          begin
            File.read(filename)
            tape[ptr] = 0
          rescue
            puts "Error loading file"
            return
          end
        end
      end
    when "," # read single byte input
      begin
        input = STDIN.getbyte
        tape[ptr] = input if input
      rescue
        puts "Error reading input"
      end
    when "." # print cell as char
      print tape[ptr].chr
    when "loop[" # start loop
      loop_stack.push(i)
    when "]" # end loop
      if tape[ptr] != 0
        if loop_stack.empty?
          puts "Unmatched ]"
          return
        end
        i = loop_stack.last
      else
        loop_stack.pop unless loop_stack.empty?
      end
    else
      puts "#{RED}error caught while parsing"
      puts "#{RED}at line: #{line}"
      return
    end
    
    i += 1
  end
  puts
end

# Run main if this file is executed directly
if __FILE__ == $0
  main
end
#good job Andrew i guess