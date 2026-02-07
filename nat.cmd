@echo off
REM nat.cmd - Windows wrapper to run nat.bash reliably (handles CRLF/LF).
REM Requirements: Git Bash (bash in PATH) OR WSL bash.
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "BASH=bash.exe"

where %BASH% >nul 2>nul
if errorlevel 1 (
  if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
  if exist "%ProgramFiles%\Git\usr\bin\bash.exe" set "BASH=%ProgramFiles%\Git\usr\bin\bash.exe"
  if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
  if exist "%ProgramFiles(x86)%\Git\usr\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\usr\bin\bash.exe"
)

if not exist "%BASH%" (
  echo bash.exe not found. Install Git for Windows (Git Bash) or use WSL.
  exit /b 127
)

if not exist "%SCRIPT_DIR%nat.bash" (
  echo nat.bash not found next to nat.cmd
  exit /b 2
)

REM Convert to LF into a temp file (in case the checkout used CRLF)
set "TMPBASH=%TEMP%\nat_%RANDOM%_%RANDOM%.bash"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$c = Get-Content -Raw -Encoding UTF8 '%SCRIPT_DIR%nat.bash'; $c = $c -replace \"`r`n\",\"`n\"; [IO.File]::WriteAllText('%TMPBASH%', $c, [Text.UTF8Encoding]::new($false))" >nul

"%BASH%" "%TMPBASH%" %*
set "EC=%ERRORLEVEL%"

del /f /q "%TMPBASH%" >nul 2>nul
exit /b %EC%
