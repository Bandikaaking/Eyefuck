#!/bin/sh
# Build EyeFuck Rust object file on Linux/UNIX/BSD and install to /usr/local/bin

NAME=eyefuck.rs
SRC_DIR="main/rust(main)"
INSTALL_DIR="/usr/local/bin/"
OUTPUT_NAME=eyefuck

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

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
    rustc $NAME -o $OUTPUT_NAME
) &

# Animate progress bar
progress_bar

# Wait for build to finish
wait

clear

# Install
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Creating install directory $INSTALL_DIR...${RESET}"
    sudo mkdir -p "$INSTALL_DIR"
fi

echo -e "${GREEN}Moving object file to $INSTALL_DIR...${RESET}"
sudo mv -f "$OUTPUT_NAME" "$INSTALL_DIR/$OUTPUT_NAME"
sudo chmod +r "$INSTALL_DIR/$OUTPUT_NAME"

echo -e "${CYAN}>> Done! $OUTPUT_NAME is now in $INSTALL_DIR.${RESET}"
echo -e "${YELLOW}[comment] if you notice any problem please open an issue on GitHub!${RESET}"
echo -e "${GREEN}Enjoy EyeFuck!${RESET}"
