@echo off
REM ========================================
REM Køkkenlager Optælling - Installer
REM Genererer UNIKT installations-ID
REM ========================================

chcp 65001 >nul 2>&1
cls

echo ========================================
echo Køkkenlager Optælling - Installer
echo ========================================
echo.
echo Denne installer genererer et UNIKT installations-ID
echo for hver installation!
echo.

cd /d "%~dp0"

REM Tjek filer
echo Tjekker filer...
if not exist "køkkenlagerprogram.html" (
    echo [FEJL] køkkenlagerprogram.html ikke fundet!
    pause
    exit /b 1
)
if not exist "manuel-optaelling.html" (
    echo [FEJL] manuel-optaelling.html ikke fundet!
    pause
    exit /b 1
)
if not exist "manuel-optaelling-manifest.json" (
    echo [FEJL] manuel-optaelling-manifest.json ikke fundet!
    pause
    exit /b 1
)
echo [OK] Alle filer fundet
echo.

REM Opret installationsmappe med nyt navn
set "INSTALL_PATH=%USERPROFILE%\Documents\køkkenlager optælling"
echo Opretter installationsmappe: %INSTALL_PATH%

if not exist "%INSTALL_PATH%" (
    mkdir "%INSTALL_PATH%"
    if errorlevel 1 (
        echo [FEJL] Kunne ikke oprette mappe!
        pause
        exit /b 1
    )
    echo [OK] Mappe oprettet
) else (
    echo [OK] Mappe eksisterer allerede
)
echo.

REM Generer UNIKT installations-ID
echo Genererer UNIKT installations-ID...
REM Brug computer navn, bruger navn, timestamp og random
for /f "tokens=2 delims==" %%a in ('wmic computersystem get name /value') do set COMPUTER_NAME=%%a
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set DATETIME=%%a
set "RAND1=%RANDOM%%RANDOM%"
set "RAND2=%RANDOM%%RANDOM%"
set "RAND3=%RANDOM%%RANDOM%"

REM Generer ID i samme format som programmet: INST-XXXXX-XXXXX-XXXXX
set "INSTALL_ID=INST-%RAND1:~-5%-%RAND2:~-5%-%RAND3:~-5%"

REM Gem installations-ID
echo %INSTALL_ID% > "%INSTALL_PATH%\INSTALLATION_ID.txt"
echo [OK] Installations-ID genereret: %INSTALL_ID%
echo.

REM Opret installations-ID JavaScript fil der injiceres i programmet
echo Opretter installations-ID fil...
(
echo // Installations-ID genereret ved installation
echo // Dette ID er unikt for denne installation
echo const PRE_GENERATED_INSTALLATION_ID = '%INSTALL_ID%';
) > "%INSTALL_PATH%\installation_id.js"
echo [OK] installation_id.js oprettet
echo.

REM Kopier filer
echo Kopierer filer...
copy /Y "køkkenlagerprogram.html" "%INSTALL_PATH%\" >nul
if errorlevel 1 (
    echo [FEJL] Kunne ikke kopiere køkkenlagerprogram.html
    pause
    exit /b 1
)
echo [OK] køkkenlagerprogram.html kopieret

copy /Y "manuel-optaelling.html" "%INSTALL_PATH%\" >nul
if errorlevel 1 (
    echo [FEJL] Kunne ikke kopiere manuel-optaelling.html
    pause
    exit /b 1
)
echo [OK] manuel-optaelling.html kopieret

copy /Y "manuel-optaelling-manifest.json" "%INSTALL_PATH%\" >nul
if errorlevel 1 (
    echo [FEJL] Kunne ikke kopiere manuel-optaelling-manifest.json
    pause
    exit /b 1
)
echo [OK] manuel-optaelling-manifest.json kopieret

REM Kopier skabelon fil hvis den findes
if exist "varelager_skabelon.csv" (
    copy /Y "varelager_skabelon.csv" "%INSTALL_PATH%\varelager_skabelon.csv" >nul
    if not errorlevel 1 (
        echo [OK] varelager_skabelon.csv kopieret
    )
) else if exist "varelager_skabelon (10).csv" (
    copy /Y "varelager_skabelon (10).csv" "%INSTALL_PATH%\varelager_skabelon.csv" >nul
    if not errorlevel 1 (
        echo [OK] varelager_skabelon.csv kopieret
    )
)
echo.

REM HTML filen er allerede opdateret til at bruge installation_id.js
echo [OK] Program er klar til at bruge installations-ID
echo.

REM Opret start script
echo Opretter start script...
(
echo @echo off
echo chcp 65001 ^>nul
echo start "" "%INSTALL_PATH%\køkkenlagerprogram.html"
) > "%INSTALL_PATH%\START_PROGRAM.bat"
echo [OK] START_PROGRAM.bat oprettet
echo.

REM Opret også start script til manuel optælling
(
echo @echo off
echo chcp 65001 ^>nul
echo start "" "%INSTALL_PATH%\manuel-optaelling.html"
) > "%INSTALL_PATH%\START_MANUEL_OPTÆLLING.bat"
echo [OK] START_MANUEL_OPTÆLLING.bat oprettet
echo.

REM Opret shortcuts med ikoner
echo Opretter ikoner på skrivebordet...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $desktop = [Environment]::GetFolderPath('Desktop'); $mainShortcut = $WshShell.CreateShortcut($desktop + '\Køkkenlager Optælling.lnk'); $mainShortcut.TargetPath = '%INSTALL_PATH%\køkkenlagerprogram.html'; $mainShortcut.WorkingDirectory = '%INSTALL_PATH%'; $mainShortcut.Description = 'Køkkenlager Optælling - Hovedprogram'; $iconPath = '%SystemRoot%\System32\imageres.dll,67'; if (Test-Path '%CD%\program_ikon.ico') { $iconPath = '%CD%\program_ikon.ico' }; $mainShortcut.IconLocation = $iconPath; $mainShortcut.Save(); Write-Host 'Ikon oprettet: Køkkenlager Optælling.lnk'"

powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $desktop = [Environment]::GetFolderPath('Desktop'); $manualShortcut = $WshShell.CreateShortcut($desktop + '\Manuel Optælling.lnk'); $manualShortcut.TargetPath = '%INSTALL_PATH%\manuel-optaelling.html'; $manualShortcut.WorkingDirectory = '%INSTALL_PATH%'; $manualShortcut.Description = 'Køkkenlager Optælling - Manuel Optælling'; $iconPath = '%SystemRoot%\System32\imageres.dll,67'; if (Test-Path '%CD%\program_ikon.ico') { $iconPath = '%CD%\program_ikon.ico' }; $manualShortcut.IconLocation = $iconPath; $manualShortcut.Save(); Write-Host 'Ikon oprettet: Manuel Optælling.lnk'"

echo [OK] Ikoner oprettet på skrivebordet
echo.

REM Opret README
echo Opretter README...
(
echo Køkkenlager Optælling
echo =====================
echo.
echo Installation fuldført!
echo.
echo Dit UNIKKE installations-ID er:
echo %INSTALL_ID%
echo.
echo VIKTIGT: Gem dette ID et sikkert sted!
echo Du skal bruge det når du bestiller en licens.
echo.
echo Du kan også finde dette ID i:
echo - INSTALLATION_ID.txt filen
echo - Programmet under "Licens" menuen
echo.
echo Start programmet ved at dobbeltklikke på:
echo - START_PROGRAM.bat
echo - Eller køkkenlagerprogram.html direkte
echo - Eller ikonet på skrivebordet: "Køkkenlager Optælling"
) > "%INSTALL_PATH%\README.txt"
echo [OK] README.txt oprettet
echo.

echo ========================================
echo Installation fuldført!
echo ========================================
echo.
echo Installationsmappe: %INSTALL_PATH%
echo.
echo ════════════════════════════════════
echo   DIT UNIKKE INSTALLATIONS-ID
echo ════════════════════════════════════
echo.
echo %INSTALL_ID%
echo.
echo ════════════════════════════════════
echo.
echo VIKTIGT: Gem dette ID et sikkert sted!
echo Du skal bruge det når du bestiller en licens.
echo.
echo Du kan nu starte programmet ved at:
echo   - Dobbeltklikke på START_PROGRAM.bat
echo   - Eller dobbeltklikke direkte på køkkenlagerprogram.html
echo   - Eller brug ikonet på skrivebordet: "Køkkenlager Optælling"
echo.
echo ════════════════════════════════════
echo VIKTIGT VED FØRSTE OPGANG:
echo ════════════════════════════════════
echo 1. Du skal oprette et nyt password
echo 2. Lageret starter tomt - ingen test data
echo 3. Importer varer fra varelager_skabelon.csv
echo    (Findes i installationsmappen)
echo ════════════════════════════════════
echo.

REM Åbn installationsmappen
start "" explorer.exe "%INSTALL_PATH%"

pause

