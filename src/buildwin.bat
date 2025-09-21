@echo off
REM Build EyeFuck for Windows using Rust

SETLOCAL ENABLEDELAYEDEXPANSION

REM Colors
set "RED=0C"
set "GREEN=0A"
set "YELLOW=0E"
set "CYAN=0B"

echo ========================================
echo Building EyeFuck for Windows...
echo ========================================

REM Set variables
set "SRC_DIR=%~dp0main\rust(main)"
set "TARGET_DIR=C:\Windows"
set "EXE_NAME=eyefuck.exe"
set "RUST_FILE=%SRC_DIR%\eyefuck.rs"

REM Check if rustc is installed
where rustc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    color %RED%
    echo Rust is not installed or not in PATH!
    echo Install it from https://www.rust-lang.org/tools/install
    pause
    exit /b 1
)
color %CYAN%

REM Remove old binary if exists
if exist "%TARGET_DIR%\%EXE_NAME%" del "%TARGET_DIR%\%EXE_NAME%"

REM Build the exe
rustc "%RUST_FILE%" -o "%TARGET_DIR%\%EXE_NAME%"
if %ERRORLEVEL% NEQ 0 (
    color %RED%
    echo ERROR: Build failed. Make sure eyefuck.rs exists and you have admin rights.
    pause
    exit /b 1
)

color %GREEN%
echo ========================================
echo DONE! EyeFuck is now in %TARGET_DIR%
echo You can now run 'eyefuck' from any terminal
echo If you find any problems, open an issue on GitHub
echo ========================================
pause
