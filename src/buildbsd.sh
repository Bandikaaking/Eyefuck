#!/bin/sh
# Build EyeFuck interpreter on Linux/UNIX/BSD

BINARY=eyefuck
INSTALL_DIR=/usr/local/bin

# Colors
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

cd main/go || { echo -e "${RED}Cannot cd to main/go${RESET}"; exit 1; }

echo -e "${CYAN}Building $BINARY for Linux/UNIX/BSD...${RESET}"

# Prograss bar cus I AM bored
progress_bar() {
    local width=30
    local duration=3  # total duration in seconds
    local sleep_time=$(awk "BEGIN {print $duration/$width}")
    for i in $(seq 0 $width); do
        done_bar=$(printf "%0.s=" $(seq 1 $i))
        left_bar=$(printf "%0.s " $(seq 1 $((width - i))))
        perc=$(( i * 100 / width ))
        printf "\r[${GREEN}${done_bar}${RESET}${left_bar}] ${perc}%%"
        sleep $sleep_time
    done
    echo ""
}

# Run build in background
(
    GO111MODULE=off go build -o $BINARY eyefuck.go
) &

# Animate progress bar (same duration)
progress_bar

# Wait for build to finish
wait

# Install
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Creating install directory $INSTALL_DIR...${RESET}"
    sudo mkdir -p "$INSTALL_DIR"
fi

echo -e "${GREEN}Moving binary to $INSTALL_DIR...${RESET}"
sudo mv -f $BINARY "$INSTALL_DIR/$BINARY"
sudo chmod +x "$INSTALL_DIR/$BINARY"

echo -e "${CYAN}>> Done! $BINARY is now installed in $INSTALL_DIR and should be in your PATH.${RESET}"
echo -e "${YELLOW}[comment] if you notice any problem please open an issue in github!${RESET}"
echo -e "${GREEN}Enjoy EyeFuck!${RESET}"
