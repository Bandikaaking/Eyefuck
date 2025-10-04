# BIG UPDATE!!!

now **Eyefuck** can be COMPILED and INTERPRETERD and REPL-ed!!

see?

all you need is just FASM

## install `FASM` in **Windows**

*(i recommend doing it via scoop)*

```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop bucket add extras

scoop install fasm

```

## Install ``FASM`` (the CLI command) in linux / BSD distros:

with `apt` (on DEBIAN-based systems, like: Ubuntu,Debian,Pop!_Os etc. et.c)
```bash
sudo apt update 
sudo apt install fasm
```


On Red-Hat-based systems (like Fedora,Red hat linux,AlmaLinux, ClearOS)

Becuse i am a windows user **do not know if red hat based systems have the CLI FASM, in their package.

```bash
dnf seach fasm
sudo dnf install fasm # only if found
```
if there is no fasm, you can download the **Official Binary**
```bash
wget https://flatassembler.net/download.php
tar -xvzf fasm-1.73.23.tgz
sudo mv fasm/fasm /usr/local/bin/
chmod +x /usr/local/bin/fasm
```

Arch-Based distros (Manjaro, Endveavour etc.)
In arch-based distros they have fasm in AUR

```bash
sudo pacman -S fasm
```
or with AUR, if it is not in the core rep
```bash
yay -S fasm
```

BSD distros:

```bash
pkg install fasm
```

SUSE system-s:
```bash
sudo zypper install fasm
```

## Problems

the ANSI highliting

well there is no problem with it if you use the VS code terminal, but *there* is a problem with it, and i AM lazy to do it, so if you know the problem, **__PLS__** OPEN a Pull request


IF you use win11 terminal it will work but if you use win 10 <       it will NOT



## Langs i wrote eyfuck
(from old to new)
- Go
- Rust
- C#
- ruby
- lua
- C
- C++
- Nim
- Php
- Python
- VisualBasic
- F#

## Langs my Friend and my Teacher wrote
- HolyC
- Zig
- LolCode

# Well...

i never taught getting this far under 2 week, my friend even my TEACHER helped me, really thanks for
- Tom: He maked the HolyC and the Zig code!
<br>
and my 
- **Programming Teacher** who maked the Lolcode code!



**EyeFuck** is a lightweight Brainfuck-like language and interpreter, created by Bandika in 2025.  
It features a simpler syntax, a complete interpreter, and a  **__REPL__** mode. It also features 2 more commands



## Installation

### Windows
1. Run `buildwin.bat` **as Administrator**.
2. This will compile `eyefuck.rs` and place `eyefuck.exe` in `C:\Windows`.

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

### Start REPL
```
eyefuck -i
or
eyefuck i
eyefuck --i
eyefuck repl
eyefuck -repl
eyefuck --repl
eyefuck --REPL
eyefuck REPL
```
Example:
```bash
eyefuck -i

Eyefuck DEV 2025 - REPL
Type commands below, empty line to execute, Ctrl+C to exit

> bin 01001000
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
