' am i the only one that think VB looks like lua?

Imports System
Imports System.IO
Imports System.Text.RegularExpressions

Module EyefuckInterpreter
    ' ANSI colors
    Const RESET As String = vbEsc & "[0m"
    Const RED As String = vbEsc & "[31m"
    Const GREEN As String = vbEsc & "[32m"
    Const YELLOW As String = vbEsc & "[33m"
    Const BLUE As String = vbEsc & "[34m"
    Const CYAN As String = vbEsc & "[36m"
    Const WHITE As String = vbEsc & "[97m"
    
    Const EYF_V As Single = 1.2
    Const TAPE_SIZE As Integer = 300000
    
    ' VB doesn't have vbEsc constant, so we define it
    Private ReadOnly vbEsc As Char = ChrW(27)

    Sub Main(args As String())
        If args.Length < 1 Then
            Console.WriteLine(RED & "Usage:" & RESET & " eyefuck <command> [file.eyf]")
            Return
        End If

        Dim mode As String = args(0)

        Select Case mode.ToLower()
            Case "run"
                If args.Length < 2 Then
                    Console.WriteLine(RED & "Please specify a file to run." & RESET)
                    Return
                End If
                Dim file As String = args(1)
                Try
                    Dim code As String = File.ReadAllText(file)
                    RunInterpreter(code)
                Catch ex As Exception
                    Console.WriteLine("Error reading file: " & ex.Message)
                End Try
                
            Case "-i", "--i", "i"
                StartREPL()
                
            Case "help", "-help", "-h", "--h", "--help"
                Console.WriteLine(CYAN & "Eyefuck HELP:" & RESET)
                Console.WriteLine(YELLOW & "  eyefuck run <file.eyf>" & RESET & "  -> " & GREEN & "execute the Eyefuck file" & RESET)
                Console.WriteLine(YELLOW & "  eyefuck -i" & RESET & "             -> " & GREEN & "interactive REPL mode" & RESET)
                Console.WriteLine(YELLOW & "  eyefuck about" & RESET & "          -> " & GREEN & "information about this interpreter" & RESET)
                
            Case "about"
                Console.WriteLine(CYAN & "Eyefuck DEV 2025" & RESET)
                Console.WriteLine(GREEN & "MIT license" & RESET & " see LICENSE for more information")
                Console.WriteLine("Please help me motive by giving the repo a star")
                Console.WriteLine(BLUE & "github:" & RESET & " github.com/bandikaaking")
                Console.WriteLine("crafted with " & RED & "<3" & RESET & " by " & YELLOW & "@Bandikaaking" & RESET)
                
            Case "version", "--v", "--version", "-v", "v", "-version"
                Console.WriteLine("Current eyefuck version: " & EYF_V)
                
            Case "ov", "-ov", "--ov"
                Console.WriteLine("Other Eyefuck versions: ")
                Console.WriteLine("0.10: Started / added 2 instructions")
                Console.WriteLine("0.11-0.43: Fixed many bugs, and edded 5 more instructions")
                Console.WriteLine("1.0: Added syntax highliting")
                Console.WriteLine("1.1: Fixed bugs")
                Console.WriteLine("added more eyefuck modes / rewrited README.md")
                
            Case Else
                Console.WriteLine(RED & "Unknown mode:" & RESET & " " & mode)
        End Select
    End Sub

    ' ---------------------------
    ' Interactive REPL
    ' ---------------------------
    Sub StartREPL()
        Console.WriteLine(CYAN & "Eyefuck DEV 2025 - REPL" & RESET)
        Console.WriteLine("Type commands below, empty line to execute, Ctrl+C to exit")
        
        Dim codeLines As New List(Of String)()
        
        While True
            Console.Write("$ ")
            Dim line As String = Console.ReadLine()
            
            If String.IsNullOrEmpty(line) Then
                RunInterpreter(String.Join(Environment.NewLine, codeLines))
                codeLines.Clear()
                Continue While
            End If
            
            codeLines.Add(line)
        End While
    End Sub

    ' ---------------------------
    ' Eyefuck Interpreter
    ' ---------------------------
    Sub RunInterpreter(code As String)
        Dim tape(TAPE_SIZE - 1) As Byte
        Dim ptr As Integer = 0
        Dim lines() As String = code.Split({Environment.NewLine, vbCr, vbLf}, StringSplitOptions.None)
        Dim loopStack As New Stack(Of Integer)()
        
        For i As Integer = 0 To lines.Length - 1
            Dim line As String = lines(i).Trim()
            
            ' remove comments after #
            Dim commentIndex As Integer = line.IndexOf("#"c)
            If commentIndex >= 0 Then
                line = line.Substring(0, commentIndex).Trim()
            End If
            
            If String.IsNullOrEmpty(line) Then Continue For

            Select Case line
                Case "^" ' increment cell
                    tape(ptr) = CByte((tape(ptr) + 1) And 255)
                    
                Case "v" ' decrement cell
                    tape(ptr) = CByte((tape(ptr) - 1) And 255)
                    
                Case ">" ' move pointer right
                    ptr = (ptr + 1) Mod TAPE_SIZE
                    
                Case "<" ' move pointer left
                    ptr = If(ptr = 0, TAPE_SIZE - 1, ptr - 1)
                    
                Case Else
                    If line.StartsWith("bin") Then
                        ' set cell from binary
                        Dim binStr As String = line.Substring(3).Trim()
                        Try
                            tape(ptr) = Convert.ToByte(binStr, 2)
                        Catch
                            Console.WriteLine("Invalid binary format")
                            Return
                        End Try
                    ElseIf line.StartsWith("col") Then
                        ' set text color from HEX
                        Dim match As Match = Regex.Match(line, "\[([0-9A-Fa-f]+)\]")
                        If match.Success Then
                            Dim hex As String = match.Groups(1).Value
                            Try
                                Dim colorInt As Integer = Convert.ToInt32(hex, 16)
                                Dim r As Integer = (colorInt >> 16) And &HFF
                                Dim g As Integer = (colorInt >> 8) And &HFF
                                Dim b As Integer = colorInt And &HFF
                                Console.Write(vbEsc & "[38;2;{0};{1};{2}m", r, g, b)
                            Catch
                                Console.WriteLine("Invalid HEX color")
                                Return
                            End Try
                        End If
                    ElseIf line.StartsWith("load[") Then
                        ' load file
                        Dim match As Match = Regex.Match(line, "\[([^\]]+)\]")
                        If match.Success Then
                            Dim filename As String = match.Groups(1).Value
                            If File.Exists(filename) Then
                                tape(ptr) = 0
                            End If
                        End If
                    ElseIf line = "," Then
                        ' read single byte input
                        Dim input As Integer = Console.Read()
                        If input <> -1 Then
                            tape(ptr) = CByte(input And 255)
                        End If
                    ElseIf line = "." Then
                        ' print cell as char
                        Console.Write(Chr(tape(ptr)))
                    ElseIf line = "loop[" Then
                        ' start loop
                        loopStack.Push(i)
                    ElseIf line = "]" Then
                        ' end loop
                        If tape(ptr) <> 0 Then
                            If loopStack.Count > 0 Then
                                i = loopStack.Peek()
                            Else
                                Console.WriteLine("Unmatched ]")
                                Return
                            End If
                        Else
                            If loopStack.Count > 0 Then
                                loopStack.Pop()
                            End If
                        End If
                    Else
                        Console.WriteLine(RED & "error caught while parsing")
                        Console.WriteLine(RED & "at line: " & line & RESET)
                        Return
                    End If
            End Select
        Next
        
        Console.WriteLine()
    End Sub
End Module
