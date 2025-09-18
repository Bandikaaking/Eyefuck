## Problems

it was good but now it is fucked up, idk

and **__**There are problems with the command highliting too**__**

annnnnnnnndddd i there is no build file for the c# and for the rust version i will write that sometime, okay?


well there is no problem with it if you use the VS code terminal, but *there* is a problem with it, and i AM lazy to do it, so if you know the problem, **__PLS__** OPEN a Pull request


IF you use win11 terminal it will work but if you use win 10 <       it will NOT

**EyeFuck** is a lightweight Brainfuck-like language and interpreter, created by Bandika in 2025.  
It features a simpler syntax, a complete interpreter, and a  **__REPL__** mode. It also features 2 more commands


---

## Installation

### Windows
1. Run `buildwin.bat` **as Administrator**.
2. This will compile `eyefuck.go` and place `eyefuck.exe` in `C:\Windows`.

*(Don't be afraid cus it copies it to C:\Windows no problem will occuer commands like "qemu" is in C:\Windows cus it is already in PATH)*
### How to get Syntax Higliting

First you will see a syntaxes.vsix in the syntax/ folder



![step1](/src/pictures/win3.png)

Next you need to go to the **Extension Manager**, Press CTR+SHIFT+X

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
```bash
eyefuck -i

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
- `loop[ ... ]` — loop while current cell not equals to  0
- `col[(color HEX value)]` — sets current AND after cells to color, so texts  will be printed with colors
- `load[(filename)]` — Loads the file and stores it at current cell
- `# <comment>` — comments

---

## Examples

- `hello.eyf` — prints "Hello World"
- More examples are in the `examples/` folder.

---

# For more codes

Go to <a href="src/examples/"> The example folders </a>

## License

MIT License. See `LICENSE` for details.


# If you notice any problems

Please open a pull request it would help me a **__****LOT****__**.

thanks for using Eyefuck🥰!
