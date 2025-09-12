
@echo off
REM you need to run this file with admin rights, or it will not be downloaded System WIDE

SETLOCAL

echo ========================================
echo Building EyeFuck for Windows...
echo ========================================

REM Set variables
set SRC_DIR=%~dp0
set TARGET_DIR=C:\Windows
set EXE_NAME=eyefuck.exe
set GO_FILE=%SRC_DIR%eyefuck.go

REM Check if Go is installed
where go >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Go is not installed or not in PATH!
    pause
    exit /b 1
)

REM Build eyefuck.exe
go env -w GO111MODULE=off
go build -o "%TARGET_DIR%\%EXE_NAME%" "%GO_FILE%"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed. Make sure eyefuck.go exists and you have admin rights.
    pause
    exit /b 1
)

echo ========================================
echo DONE! EyeFuck is now in %TARGET_DIR%
echo REFRESH your PowerShell/terminal to use the 'eyefuck' command
echo if you find any problems open an issue on github, or just want to add tips for the future
echo "2025 Eyefuck dev, crafted with <3"
echo ========================================
pause
