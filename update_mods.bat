@echo off
title Advanced Minecraft Mod Updater
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
:: GET THESE LINKS: Go to your .txt files on GitHub, click "Raw", and copy the URL from your browser's address bar.
set ADD_LIST_URL=https://raw.githubusercontent.com/Realm07/mmmModsList/main/mods_to_add.txt
set REMOVE_LIST_URL=https://raw.githubusercontent.com/Realm07/mmmModsList/main/mods_to_remove.txt

:: --- DO NOT EDIT BELOW THIS LINE ---

:: Set the mods directory relative to the script's location.
:: This assumes the .bat file is in the "game" folder, and "mods" is inside "game".
set "MODS_DIR=%~dp0mods"

:: Check if the mods directory exists, and create it if it doesn't.
if not exist "%MODS_DIR%" (
    echo "mods" folder not found. Creating it now...
    mkdir "%MODS_DIR%"
)

echo.
echo =================================
echo    ADVANCED MODPACK UPDATER
echo =================================
echo.
echo IMPORTANT: Make sure this file is inside your main 'game' folder!
echo.
echo This will remove old mods and download any new or updated mods.
echo Target folder: %MODS_DIR%
echo.
pause
echo.

:: Step 1: Remove outdated mods
echo [1/3] Checking for mods to remove...
curl -L -s -o "%TEMP%\removelist.txt" "%REMOVE_LIST_URL%"

if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Could not download the removal list. Skipping removal step.
) else (
    if exist "%TEMP%\removelist.txt" (
        for /f "usebackq delims=" %%F in ("%TEMP%\removelist.txt") do (
            if exist "%MODS_DIR%\%%F" (
                echo  - Deleting %%F
                del "%MODS_DIR%\%%F"
            )
        )
    )
)
echo Removal complete.
echo.

:: Step 2: Get the list of mods to add/update
echo [2/3] Downloading new mod list...
curl -L -s -o "%TEMP%\addlist.txt" "%ADD_LIST_URL%"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not download the main mod list! The update cannot continue.
    goto cleanup
)
echo Download list retrieved.
echo.

:: Step 3: Check and download missing mods
echo [3/3] Checking your mods folder and downloading missing files...
echo ================================================================

for /f "usebackq delims=" %%U in ("%TEMP%\addlist.txt") do (
    set "URL=%%U"
    for %%N in (!URL!) do set "FILENAME=%%~nxN"
    
    if not exist "%MODS_DIR%\!FILENAME!" (
        echo  + Downloading !FILENAME!
        curl -L -o "%MODS_DIR%\!FILENAME!" "!URL!"
        if !ERRORLEVEL! NEQ 0 echo    ^> ERROR: Download failed for !FILENAME!
    )
)

echo ================================================================
echo.

:cleanup
if exist "%TEMP%\removelist.txt" del "%TEMP%\removelist.txt"
if exist "%TEMP%\addlist.txt" del "%TEMP%\addlist.txt"

echo Update process finished!
echo You can now close this window and launch Minecraft.
echo.
pause