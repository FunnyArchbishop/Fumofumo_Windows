@echo off
REM Build WINobj.exe (onedir mode), trim unused Qt modules, and zip the result.
REM
REM Output:
REM   dist\WINobj\WINobj.exe            <- run this
REM   dist\WINobj-<version>-win64.zip   <- what gets attached to a GitHub release
REM
REM Notes:
REM   * Run this from a Python env that has: PySide6 moderngl trimesh pillow numpy pyinstaller
REM   * usd-core is optional. If it is NOT installed, delete the "--collect-all pxr" line.
REM   * scipy is deliberately excluded (the app has a numpy fallback and it would add ~100 MB).
REM   * torch / matplotlib / tkinter are excluded on purpose: unused, and they balloon the build.
REM   * trim_dist.py removes ~50 MB of Qt modules the app never loads (see that file for the list).
chcp 65001 >nul
setlocal
cd /d "%~dp0"

set VERSION=1.0.0

echo [1/3] PyInstaller...
python -m PyInstaller --noconfirm --clean --onedir --windowed ^
  --name WINobj ^
  --icon Fumofumo_icon.png ^
  --add-data "Fumofumo_icon.png;." ^
  --add-data "Fumofumo_tray.ico;." ^
  --collect-all pxr ^
  --exclude-module torch ^
  --exclude-module torchvision ^
  --exclude-module torchaudio ^
  --exclude-module matplotlib ^
  --exclude-module IPython ^
  --exclude-module tkinter ^
  --exclude-module scipy ^
  --exclude-module pytest ^
  --exclude-module pandas ^
  WINobj.py
if errorlevel 1 goto fail

echo.
echo [2/3] Trimming unused Qt modules...
python trim_dist.py
if errorlevel 1 goto fail

echo.
echo [3/3] Zipping...
if exist "dist\WINobj-%VERSION%-win64.zip" del /q "dist\WINobj-%VERSION%-win64.zip"
powershell -NoProfile -Command "Compress-Archive -Path 'dist\WINobj\*' -DestinationPath 'dist\WINobj-%VERSION%-win64.zip' -CompressionLevel Optimal"
if errorlevel 1 goto fail

echo.
echo Done.
echo   exe : dist\WINobj\WINobj.exe
echo   zip : dist\WINobj-%VERSION%-win64.zip
pause
exit /b 0

:fail
echo.
echo BUILD FAILED
pause
exit /b 1
