@echo off
REM Setup Git Hooks for ZMK Config
REM 
REM This script installs the pre-commit hook that automatically
REM syncs generic keymaps before each commit

setlocal enabledelayedexpansion

echo Setting up Git hooks...
echo.

REM Get the repo root
for /f "delims=" %%i in ('git rev-parse --show-toplevel') do set REPO_ROOT=%%i
set HOOKS_DIR=%REPO_ROOT%\.git\hooks
set PRE_COMMIT_HOOK=%HOOKS_DIR%\pre-commit
set SOURCE_HOOK=%REPO_ROOT%\scripts\pre-commit

REM Check if source hook exists
if not exist "%SOURCE_HOOK%" (
    echo Error: scripts\pre-commit not found
    exit /b 1
)

REM Backup existing pre-commit hook if it exists
if exist "%PRE_COMMIT_HOOK%" (
    echo Backing up existing pre-commit hook...
    move "%PRE_COMMIT_HOOK%" "%PRE_COMMIT_HOOK%.backup" >nul
    echo    Saved to: %PRE_COMMIT_HOOK%.backup
    echo.
)

REM Copy hook (Windows doesn't support symlinks easily)
echo Installing pre-commit hook...
copy "%SOURCE_HOOK%" "%PRE_COMMIT_HOOK%" >nul

echo.
echo Git hooks installed successfully!
echo.
echo What this does:
echo    - Before each commit, automatically syncs:
echo      - generic_3x5.keymap to generic_3x6.keymap
echo      - Both keymaps to .dtsi files
echo    - Adds synced files to your commit
echo    - Ensures all boards stay in sync
echo.
echo To disable temporarily:
echo    git commit --no-verify
echo.
echo To uninstall:
echo    del %PRE_COMMIT_HOOK%
echo.

endlocal
