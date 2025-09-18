# EyeFuck

## There is a problem with the .vsix file

it was good but now it is fucked up, idk

and **__**There are problems with the command highliting too**__**


well there is no problem with it if you use the VS code terminal, but *there* is a problem with it, and i AM lazy to do it, so if you know the problem, **__PLS__** OPEN a Pull request


**EyeFuck** is a lightweight Brainfuck-like language and interpreter, created by Bandika in 2025.  
It features a simpler syntax, and a  **__REPL__** mode.


---

## Installation

### Windows
1. Run `buildwin.bat` **as Administrator**.
2. This will compile `eyefuck.go` and place `eyefuck.exe` in `C:\Windows`.
3. `C:\Windows` is already in PATH, so you can run `eyefuck` from any terminal.
### How to get Syntax Higliting

First you will see a syntaxes.vsix in the syntax/ folder



![step1](/src/pictures/win3.png)

Next you need to go to the **Extension Manager** Press CTR+SHIFT+X

then, you would find 3 dots, click on it, then select *"Install from VSIX..."*

![step2](/src/pictures/Windows1.png)

then select the syntaxes.vsix

![step3](/src/pictures/windows2.png)

---

Now you Have EyeFuck support 

### Linux/macOS/BSD
- Use the respective build scripts: `buildlinux.sh`, `buildmac.sh`, `buildbsd.sh`.

``

---

## Usage

### Run a program
```bash
eyefuck run <file.eyf>
```

### Start interactive REPL
```bash
eyefuck -i
```
Example:
```
Eyefuck DEV 2025
> set 01001000
> .
> 
> ...
```

### Help & About
```bash
eyefuck help
eyefuck about
```

---

## Syntax

- `bin <binary>` — sets current cell to a binary value
- `^` — increment current cell
- `v` — decrement current cell
- `>` — move pointer right
- `<` — move pointer left
- `.` — output current cell as ASCII
- `,` — read one character from stdin
- `loop[ ... ]` — loop while current cell != 0
- `# <comment>` — comments

---

## Examples

- `hello.eyf` — prints "Hello World"
- More examples are in the `examples/` folder.

---

# For more codes

Go to <a href="src/examples/"> The example folders </a>

# License

MIT License. See `LICENSE` for details.
