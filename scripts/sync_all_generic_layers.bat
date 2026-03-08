@echo off
REM Sync All Generic Layers
REM 
REM This script:
REM 1. Syncs generic_3x5.keymap -> generic_3x5_layers.dtsi
REM 2. Syncs generic_3x6.keymap -> generic_3x6_layers.dtsi
REM
REM Usage: scripts\sync_all_generic_layers.bat

setlocal enabledelayedexpansion

set KEYMAP_3X5=config\generic_3x5.keymap
set KEYMAP_3X6=config\generic_3x6.keymap
set DTSI_3X5=config\generic_3x5_layers.dtsi
set DTSI_3X6=config\generic_3x6_layers.dtsi

echo Syncing all generic layers...
echo.

REM Check if files exist
if not exist "%KEYMAP_3X5%" (
    echo Error: %KEYMAP_3X5% not found
    exit /b 1
)
if not exist "%KEYMAP_3X6%" (
    echo Error: %KEYMAP_3X6% not found
    exit /b 1
)

echo Step 1: Syncing 3x5 layers from %KEYMAP_3X5%...

REM Use PowerShell to do the heavy lifting
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync_all_generic_layers.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to sync layers
    exit /b 1
)

echo.
echo Successfully synced all generic layers!
echo.
echo Summary:
echo    3x5 Layers:
echo       - BASE_LAYER
echo       - NUM_LAYER
echo       - SYM_LAYER
echo       - FNC_LAYER
echo.
echo    3x6 Layers (same names as 3x5):
echo       - BASE_LAYER
echo       - NUM_LAYER
echo       - SYM_LAYER
echo       - FNC_LAYER
echo.
echo All boards using these .dtsi files will get the changes on next build!

endlocal
