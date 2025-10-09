<?php

/* did you know, i learned php first! */
/* and it's a goddamn plan to write an interpreter in an interpreter! */
// ANSI colors
define('RESET', "\033[0m");
define('RED', "\033[31m");
define('GREEN', "\033[32m");
define('YELLOW', "\033[33m");
define('BLUE', "\033[34m");
define('CYAN', "\033[36m");
define('WHITE', "\033[97m");

define('EYF_V', 1.2);
define('TAPE_SIZE', 300000);

// ---------------------------
// Main function
// ---------------------------
function main() {
    global $argv;
    
    if (count($argv) < 2) {
        echo RED . "Usage:" . RESET . " eyefuck <command> [file.eyf]\n";
        return;
    }

    $mode = $argv[1];

    switch ($mode) {
        case "run":
            if (count($argv) < 3) {
                echo RED . "Please specify a file to run." . RESET . "\n";
                return;
            }
            $file = $argv[2];
            if (!file_exists($file)) {
                echo "Error reading file\n";
                return;
            }
            $code = file_get_contents($file);
            run_interpreter($code);
            break;
            
        case "-i":
        case "--i":
        case "i":
            start_repl();
            break;
            
        case "help":
        case "-help":
        case "-h":
        case "--h":
        case "--help":
            echo CYAN . "Eyefuck HELP:" . RESET . "\n";
            echo YELLOW . "  eyefuck run <file.eyf>" . RESET . "  -> " . GREEN . "execute the Eyefuck file" . RESET . "\n";
            echo YELLOW . "  eyefuck -i" . RESET . "             -> " . GREEN . "interactive REPL mode" . RESET . "\n";
            echo YELLOW . "  eyefuck about" . RESET . "          -> " . GREEN . "information about this interpreter" . RESET . "\n";
            break;
            
        case "about":
            echo CYAN . "Eyefuck DEV 2025" . RESET . "\n";
            echo GREEN . "MIT license" . RESET . " see LICENSE for more information\n";
            echo "Please help me motive by giving the repo a star\n";
            echo BLUE . "github:" . RESET . " github.com/bandikaaking\n";
            echo "crafted with " . RED . "<3" . RESET . " by " . YELLOW . "@Bandikaaking" . RESET . "\n";
            break;
            
        case "version":
        case "--v":
        case "--version":
        case "-v":
        case "v":
        case "-version":
            echo "Current eyefuck version: " . EYF_V . "\n";
            break;
            
        case "ov":
        case "-ov":
        case "--ov":
            echo "Other Eyefuck versions: \n";
            echo "0.10: Started / added 2 instructions\n";
            echo "0.11-0.43: Fixed many bugs, and edded 5 more instructions\n";
            echo "1.0: Added syntax highliting\n";
            echo "1.1: Fixed bugs\n";
            echo "added more eyefuck modes / rewrited README.md\n";
            break;
            
        default:
            echo RED . "Unknown mode:" . RESET . " " . $mode . "\n";
            break;
    }
}

// ---------------------------
// Interactive REPL
// ---------------------------
function start_repl() {
    echo CYAN . "Eyefuck DEV 2025 - REPL" . RESET . "\n";
    echo "Type commands below, empty line to execute, Ctrl+C to exit\n";
    
    $code_lines = array();
    
    while (true) {
        echo "$ ";
        $line = trim(fgets(STDIN));
        
        if ($line === "") {
            run_interpreter(implode("\n", $code_lines));
            $code_lines = array();
            continue;
        }
        
        $code_lines[] = $line;
    }
}

// ---------------------------
// Eyefuck Interpreter
// ---------------------------
function run_interpreter($code) {
    $tape = array_fill(0, TAPE_SIZE, 0);
    $ptr = 0;
    $lines = explode("\n", $code);
    $loop_stack = array();
    
    for ($i = 0; $i < count($lines); $i++) {
        $line = trim($lines[$i]);
        
        // remove comments after #
        $comment_pos = strpos($line, '#');
        if ($comment_pos !== false) {
            $line = trim(substr($line, 0, $comment_pos));
        }
        
        if ($line === "") {
            continue;
        }

        switch ($line) {
            case "^": // increment cell
                $tape[$ptr] = ($tape[$ptr] + 1) % 256;
                break;
                
            case "v": // decrement cell
                $tape[$ptr] = ($tape[$ptr] - 1) % 256;
                break;
                
            case ">": // move pointer right
                $ptr = ($ptr + 1) % TAPE_SIZE;
                break;
                
            case "<": // move pointer left
                $ptr = $ptr == 0 ? TAPE_SIZE - 1 : $ptr - 1;
                break;
                
            default:
                if (strpos($line, "bin") === 0) {
                    // set cell from binary
                    $bin = trim(substr($line, 3));
                    $tape[$ptr] = bindec($bin) % 256;
                }
                elseif (strpos($line, "col") === 0) {
                    // set text color from HEX
                    if (preg_match('/\[([0-9A-Fa-f]+)\]/', $line, $matches)) {
                        $hex = $matches[1];
                        $color_int = hexdec($hex);
                        $r = ($color_int >> 16) & 0xFF;
                        $g = ($color_int >> 8) & 0xFF;
                        $b = $color_int & 0xFF;
                        echo "\033[38;2;{$r};{$g};{$b}m";
                    }
                }
                elseif (strpos($line, "load[") === 0) {
                    // load file
                    if (preg_match('/\[([^\]]+)\]/', $line, $matches)) {
                        $filename = $matches[1];
                        if (file_exists($filename)) {
                            $tape[$ptr] = 0;
                        }
                    }
                }
                elseif ($line === ",") {
                    // read single byte input
                    $input = fgetc(STDIN);
                    if ($input !== false) {
                        $tape[$ptr] = ord($input);
                    }
                }
                elseif ($line === ".") {
                    // print cell as char
                    echo chr($tape[$ptr]);
                }
                elseif ($line === "loop[") {
                    // start loop
                    array_push($loop_stack, $i);
                }
                elseif ($line === "]") {
                    // end loop
                    if ($tape[$ptr] != 0) {
                        if (!empty($loop_stack)) {
                            $i = end($loop_stack);
                        } else {
                            echo "Unmatched ]\n";
                            return;
                        }
                    } else {
                        if (!empty($loop_stack)) {
                            array_pop($loop_stack);
                        }
                    }
                }
                else {
                    echo RED . "error caught while parsing\n";
                    echo RED . "at line: " . $line . RESET . "\n";
                    return;
                }
                break;
        }
    }
    
    echo "\n";
}

// Run main if this file is executed directly
if (isset($argv) && count($argv) > 0 && basename($argv[0]) == basename(__FILE__)) {
    main();
}
?>