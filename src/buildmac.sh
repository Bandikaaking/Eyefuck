#!/bin/sh
# Build EyeFuck Rust object file on Linux/UNIX/BSD

BINARY=eyefuck.o
NAME=eyefuck.rs
SRC_DIR="main/rust(main)"
INSTALL_DIR="/usr/local/bin"

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

# Check if rustc is installed
if ! command -v rustc >/dev/null 2>&1; then
    echo -e "${RED}Rustc is not installed!${RESET}"
    echo -ne "${GREEN}Wanna install it from https://www.rust-lang.org/tools/install (Y/N)? ${RESET}"
    read ans
    case "$ans" in
        [Yy]* ) 
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
            export PATH="$HOME/.cargo/bin:$PATH"
            ;;
        * ) 
            echo -e "${RED}Cannot continue without Rustc.${RESET}"
            exit 1
            ;;
    esac
fi

cd "$SRC_DIR" || { echo -e "${RED}Cannot cd to $SRC_DIR${RESET}"; exit 1; }

echo -e "${CYAN}Building $NAME as object file...${RESET}"

# Progress bar function
progress_bar() {
    local width=30
    local duration=3
    local sleep_time=$(awk "BEGIN {print $duration/$width}")
    for i in $(seq 0 $width); do
        done_bar=$(printf "%0.s=" $(seq 1 $i))
        left_bar=$(printf "%0.s " $(seq 1 $((width - i)) ))
        perc=$(( i * 100 / width ))
        printf "\r[${GREEN}${done_bar}${RESET}${left_bar}] ${perc}%%"
        sleep $sleep_time
    done
    echo ""
}

# Build .o file in background
(
    rustc --emit=obj "$NAME" -o "$BINARY"
) &

# Animate progress bar
progress_bar

# Wait for build to finish
wait

# Install
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Creating install directory $INSTALL_DIR...${RESET}"
    sudo mkdir -p "$INSTALL_DIR"
fi

echo -e "${GREEN}Moving object file to $INSTALL_DIR...${RESET}"
sudo mv -f "$BINARY" "$INSTALL_DIR/$BINARY"
sudo chmod +x "$INSTALL_DIR/$BINARY"

echo -e "${CYAN}>> Done! $BINARY is now installed in $INSTALL_DIR and should be in your PATH.${RESET}"
echo -e "${YELLOW}[comment] if you notice any problem please open an issue in GitHub!${RESET}"
echo -e "${GREEN}Enjoy EyeFuck!${RESET}"
