/* Hello hello i am happy to see you! I send ChatGPT my repo link and it sayd "You should improve it, Let me help you!"  i sayd "no" proud of me??? please be */

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Csharp
{
    class Program
    {
        // ANSI colors
        const string Reset = "\u001b[0m";
        const string Red = "\u001b[31m";
        const string Green = "\u001b[32m";
        const string Yellow = "\u001b[33m";
        const string Blue = "\u001b[34m";
        const string Cyan = "\u001b[36m";
        const string White = "\u001b[97m";

        const float EyfV = 1.2f;
        const int TapeSize = 300000;

        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine($"{Red}Usage:{Reset} eyefuck <command> [file.eyf]");
                return;
            }

            string mode = args[0];

            switch (mode)
            {
                case "run":
                    if (args.Length < 2)
                    {
                        Console.WriteLine($"{Red}Please specify a file to run.{Reset}");
                        return;
                    }
                    string file = args[1];
                    try
                    {
                        string code = File.ReadAllText(file);
                        RunInterpreter(code);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine($"Error reading file: {e.Message}");
                    }
                    break;

                case "-i":
                case "--i":
                case "i":
                    StartREPL();
                    break;

                case "help":
                case "-help":
                case "-h":
                case "--h":
                case "--help":
                    Console.WriteLine($"{Cyan}Eyefuck HELP:{Reset}");
                    Console.WriteLine($"{Yellow}  eyefuck run <file.eyf>{Reset}  -> {Green}execute the Eyefuck file{Reset}");
                    Console.WriteLine($"{Yellow}  eyefuck -i{Reset}             -> {Green}interactive REPL mode{Reset}");
                    Console.WriteLine($"{Yellow}  eyefuck about{Reset}          -> {Green}information about this interpreter{Reset}");
                    break;

                case "about":
                    Console.WriteLine($"{Cyan}Eyefuck DEV 2025{Reset}");
                    Console.WriteLine($"{Green}MIT license{Reset} see LICENSE for more information");
                    Console.WriteLine("Please help me motive by giving the repo a star");
                    Console.WriteLine($"{Blue}github:{Reset} github.com/bandikaaking");
                    Console.WriteLine($"crafted with {Red}<3{Reset} by {Yellow}@Bandikaaking{Reset}");
                    break;

                case "version":
                case "--v":
                case "--version":
                case "-v":
                case "v":
                case "-version":
                    Console.WriteLine($"Current eyefuck version: {EyfV}");
                    break;

                case "ov":
                case "-ov":
                case "--ov":
                    Console.WriteLine("Other Eyefuck versions: ");
                    Console.WriteLine("0.10: Started / added 2 instructions");
                    Console.WriteLine("0.11-0.43: Fixed many bugs, and edded 5 more instructions");
                    Console.WriteLine("1.0: Added syntax highliting");
                    Console.WriteLine("1.1: Fixed bugs");
                    Console.WriteLine("added more eyefuck modes / rewrited README.md");
                    break;

                default:
                    Console.WriteLine($"{Red}Unknown mode:{Reset} {mode}");
                    break;
            }
        }

        // ---------------------------
        // Interactive REPL
        // ---------------------------
        static void StartREPL()
        {
            Console.WriteLine($"{Cyan}Eyefuck DEV 2025 - REPL{Reset}");
            Console.WriteLine("Type commands below, empty line to execute, Ctrl+C to exit");
            
            List<string> codeLines = new List<string>();
            
            while (true)
            {
                Console.Write("$ ");
                string line = Console.ReadLine()?.Trim() ?? "";
                
                if (string.IsNullOrEmpty(line))
                {
                    RunInterpreter(string.Join("\n", codeLines));
                    codeLines.Clear();
                    continue;
                }
                
                codeLines.Add(line);
            }
        }

        // ---------------------------
        // Eyefuck Interpreter
        // ---------------------------
        static void RunInterpreter(string code)
        {
            byte[] tape = new byte[TapeSize];
            int ptr = 0;
            string[] lines = code.Split('\n');
            Stack<int> loopStack = new Stack<int>();

            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i].Trim();
                
                // remove comments after #
                int commentPos = line.IndexOf('#');
                if (commentPos >= 0)
                {
                    line = line.Substring(0, commentPos).Trim();
                }
                
                if (string.IsNullOrEmpty(line))
                {
                    continue;
                }

                switch (line)
                {
                    case "^": // increment cell
                        tape[ptr] = (byte)(tape[ptr] + 1);
                        break;
                        
                    case "v": // decrement cell
                        tape[ptr] = (byte)(tape[ptr] - 1);
                        break;
                        
                    case ">": // move pointer right
                        ptr = (ptr + 1) % TapeSize;
                        break;
                        
                    case "<": // move pointer left
                        ptr = ptr == 0 ? TapeSize - 1 : ptr - 1;
                        break;
                        
                    case string s when s.StartsWith("bin"): // set cell from binary
                        string bin = s.Substring(3).Trim();
                        try
                        {
                            tape[ptr] = Convert.ToByte(bin, 2);
                        }
                        catch
                        {
                            Console.WriteLine("Invalid binary format");
                            return;
                        }
                        break;
                        
                    case string s when s.StartsWith("col"): // set text color from HEX
                        int start = s.IndexOf('[');
                        int end = s.IndexOf(']');
                        if (start == -1 || end == -1 || end <= start + 1)
                        {
                            Console.WriteLine("Invalid col syntax");
                            return;
                        }
                        string hex = s.Substring(start + 1, end - start - 1);
                        try
                        {
                            uint colorInt = Convert.ToUInt32(hex, 16);
                            byte r = (byte)((colorInt >> 16) & 0xFF);
                            byte g = (byte)((colorInt >> 8) & 0xFF);
                            byte b = (byte)(colorInt & 0xFF);
                            Console.Write($"\u001b[38;2;{r};{g};{b}m");
                        }
                        catch
                        {
                            Console.WriteLine("Invalid HEX color");
                            return;
                        }
                        break;
                        
                    case string s when s.StartsWith("load["): // load file
                        start = s.IndexOf('[');
                        end = s.IndexOf(']');
                        if (start == -1 || end == -1 || end <= start + 1)
                        {
                            Console.WriteLine("Invalid load syntax");
                            return;
                        }
                        string filename = s.Substring(start + 1, end - start - 1);
                        try
                        {
                            byte[] data = File.ReadAllBytes(filename);
                            tape[ptr] = 0;
                        }
                        catch
                        {
                            Console.WriteLine("Error loading file");
                            return;
                        }
                        break;
                        
                    case ",": // read single byte input
                        try
                        {
                            int input = Console.Read();
                            tape[ptr] = (byte)(input & 0xFF);
                        }
                        catch
                        {
                            Console.WriteLine("Error reading input");
                        }
                        break;
                        
                    case ".": // print cell as char
                        Console.Write((char)tape[ptr]);
                        break;
                        
                    case "loop[": // start loop
                        loopStack.Push(i);
                        break;
                        
                    case "]": // end loop
                        if (tape[ptr] != 0)
                        {
                            if (loopStack.Count == 0)
                            {
                                Console.WriteLine("Unmatched ]");
                                return;
                            }
                            i = loopStack.Peek();
                        }
                        else
                        {
                            if (loopStack.Count > 0)
                            {
                                loopStack.Pop();
                            }
                        }
                        break;
                        
                    default:
                        Console.WriteLine($"{Red}error caught while parsing");
                        Console.WriteLine($"{Red}at line: {line}");
                        return;
                }
            }
            Console.WriteLine();
        }
    }
}
//good job Andrew i guess