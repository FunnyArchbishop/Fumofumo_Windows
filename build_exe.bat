@echo off
REM Build Fumofumo.exe (onedir mode), trim unused Qt modules, and zip the result.
REM
REM Usage:
REM   build_exe.bat
REM   set PYTHON=C:\path\to\.venv\Scripts\python.exe  ^&^&  build_exe.bat
REM
REM If PYTHON is not set it falls back to "python" on PATH -- make sure that one
REM is a CLEAN env (no torch), otherwise the package balloons. The pre-flight
REM check below prints exactly which interpreter is used.
REM
REM Output:
REM   dist\Fumofumo\Fumofumo.exe            -^> run THIS one (needs _internal next to it)
REM   dist\Fumofumo-<version>-win64.zip   -^> attach this to a GitHub release
REM
REM Notes:
REM   * usd-core is optional. If it is NOT installed, delete the "--collect-all pxr" line.
REM   * scipy is deliberately excluded (numpy fallback exists; it would add ~100 MB).
REM   * build\ is deleted at the end: it contains a bare stub exe that cannot run alone.
chcp 65001 >nul
setlocal
cd /d "%~dp0"

set VERSION=1.2.0
if not defined PYTHON set PYTHON=python

echo [0/4] Checking Python environment...
"%PYTHON%" check_env.py
if errorlevel 1 goto fail

echo.
echo [1/4] PyInstaller...
rd /s /q build 2>nul
"%PYTHON%" -m PyInstaller --noconfirm --clean --onedir --windowed ^
  --name Fumofumo ^
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
  Fumofumo.py
if errorlevel 1 goto fail

echo.
echo [2/4] Trimming unused Qt modules...
"%PYTHON%" trim_dist.py
if errorlevel 1 goto fail

echo.
echo [3/4] Zipping...
if exist "dist\Fumofumo-%VERSION%-win64.zip" del /q "dist\Fumofumo-%VERSION%-win64.zip"
powershell -NoProfile -Command "Compress-Archive -Path 'dist\Fumofumo' -DestinationPath 'dist\Fumofumo-%VERSION%-win64.zip' -CompressionLevel Optimal"
if errorlevel 1 goto fail

echo.
echo [4/4] Removing build folder (holds a stub exe that cannot run)...
rd /s /q build 2>nul

echo.
echo Done.
echo   exe : dist\Fumofumo\Fumofumo.exe
echo   zip : dist\Fumofumo-%VERSION%-win64.zip
pause
exit /b 0

:fail
echo.
echo BUILD FAILED
pause
exit /b 1
