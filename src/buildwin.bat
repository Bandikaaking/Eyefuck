@echo off
REM =========================
REM Build EyeFuck on Windows
REM =========================

SET BINARY=eyefuck.exe
SET TARGET_DIR=C:\Windows

echo Building %BINARY% for Windows...

REM Build the executable (eyefuck.go is in the same folder as this script)
go build -o %BINARY% eyefuck.go
IF NOT EXIST "%BINARY%" (
    echo ERROR: Build failed. Make sure Go is installed and eyefuck.go exists.
    pause
    exit /b 1
)

REM Move the binary to C:\Windows
move /Y "%BINARY%" "%TARGET_DIR%\%BINARY%"

echo.
echo ========================================
echo DONE! EyeFuck is now in %TARGET_DIR%
echo REFRESH your PowerShell/terminal to use the 'eyefuck' command
echo ========================================
pause
