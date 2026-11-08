@echo off
REM Build WINobj.exe (onedir mode). Output: dist\WINobj\WINobj.exe
REM
REM Notes:
REM   * Run this from a Python env that has: PySide6 moderngl trimesh pillow numpy pyinstaller
REM   * usd-core is optional. If it is NOT installed, delete the "--collect-all pxr" line.
REM   * scipy is deliberately excluded (the app has a numpy fallback and it would add ~100 MB).
REM   * torch / matplotlib / tkinter are excluded on purpose: they are not used and make the build huge.
chcp 65001 >nul
setlocal
cd /d "%~dp0"

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

if errorlevel 1 (
  echo.
  echo BUILD FAILED
  pause
  exit /b 1
)

echo.
echo Done: dist\WINobj\WINobj.exe
pause
