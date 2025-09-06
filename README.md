# EyeFuck



**EyeFuck** is a lightweight Brainfuck-like language and interpreter, created by Bandika in 2025.  
It features a simpler syntax, REPL mode, and can compile programs to `.exe` or assembly `.S` files via Go tooling.

### to learn EyeFuck go to: https://learneyefuck.netlify.app/

---

## Installation

### Windows
1. Run `buildwin.bat` **as Administrator**.
2. This will compile `eyefuck.go` and place `eyefuck.exe` in `C:\Windows`.
3. `C:\Windows` is already in PATH, so you can run `eyefuck` from any terminal.
### How to get Syntax Higliting

First you will see a syntaxes.vsix in the syntax/ folder



![step1](/src/pictures/win3.png)

Next you need to go to the **Extension Manager** Press CTR+ALT+X

then, you would find 3 dots, click on it, then select *"Install from VSIX..."*

![step2](/src/pictures/Windows1.png)

then select the syntaces.vsix

![step3](/src/pictures/windows2.png)

---

Now you Have EyeFuck support 

### Linux/macOS/BSD
- Use the respective build scripts: `buildlinux.sh`, `buildmac.sh`, `buildbsd.sh`.

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
> print
> ...
```

### Help & About
```bash
eyefuck help
eyefuck about
```

---

## Syntax

- `set <binary>` — sets current cell to a binary value
- `^` — increment current cell
- `v` — decrement current cell
- `>` — move pointer right
- `<` — move pointer left
- `print` — output current cell as ASCII
- `input` — read one character from stdin
- `loop[ ... ]` — loop while current cell != 0
- `# <comment>` — comments

---

## Examples

- `hello.eyf` — prints "Hello World"
- More examples are in the `examples/` folder.

---

## License

MIT License. See `LICENSE` for details.
