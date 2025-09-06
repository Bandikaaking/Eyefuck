#!/bin/sh
# Build EyeFuck interpreter on BSD and add to PATH

BINARY=eyefuck
INSTALL_DIR=/usr/local/bin

echo "Building $BINARY for BSD..."

go build -o $BINARY eyefuck.go

# Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
fi

# Move binary to install dir
sudo mv -f $BINARY "$INSTALL_DIR/$BINARY"

# Make sure it's executable
sudo chmod +x "$INSTALL_DIR/$BINARY"

echo "Done! $BINARY is now installed in $INSTALL_DIR and should be in your PATH."
