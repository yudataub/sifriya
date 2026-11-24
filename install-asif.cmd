@echo off
rem Sifriya - installs the local Torah library app (search by meaning + sources reader + questions to your own Claude).
rem Everything is installed under %LOCALAPPDATA%\Sifriya . Run again any time to update the app (the data stays).
setlocal
title Sifriya - install
set "D=%LOCALAPPDATA%\Sifriya"
set "SITE=https://yudataub.github.io/sifriya"
set "PRESET=asif"
if not exist "%D%" mkdir "%D%"

echo [1/4] Looking for Python...
set "PY="
for %%P in (python.exe) do if not "%%~$PATH:P"=="" set "PY=%%~$PATH:P"
if defined PY "%PY%" -c "import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)" 2>nul || set "PY="
if not defined PY if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
if not defined PY (
  echo       Python was not found. Installing Python 3.12 ^(winget^)...
  winget install -e --id Python.Python.3.12 --scope user --accept-package-agreements --accept-source-agreements
  if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
)
if not defined PY (
  echo.
  echo Python could not be installed automatically.
  echo Install it from https://www.python.org/downloads/ ^(tick "Add python.exe to PATH"^) and run this file again.
  pause
  exit /b 1
)
echo       %PY%

echo [2/4] Downloading the app...
"%SystemRoot%\System32\curl.exe" -L -f -s -o "%D%\app.zip" "%SITE%/app.zip"
if errorlevel 1 ( echo Download failed. Check the internet connection and run this file again. & pause & exit /b 1 )
"%SystemRoot%\System32\tar.exe" -xf "%D%\app.zip" -C "%D%"
del "%D%\app.zip"

echo [3/4] Installing Python packages ^(numpy, onnxruntime, tokenizers, cryptography^)...
"%PY%" -m pip install --quiet --disable-pip-version-check numpy onnxruntime tokenizers cryptography
if errorlevel 1 ( echo Package install failed. Run this file again. & pause & exit /b 1 )

if defined PRESET (echo %PRESET%)> "%D%\preset.txt"
"%PY%" "%D%\app.py" --skill

echo [4/4] Creating a desktop shortcut and starting...
set "PYW=%PY:python.exe=pythonw.exe%"
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\Sifriya.lnk'); $s.TargetPath='%PYW%'; $s.Arguments='\"%D%\app.py\"'; $s.WorkingDirectory='%D%'; $s.IconLocation='%SystemRoot%\System32\imageres.dll,-1023'; $s.Save()"
start "" "%PYW%" "%D%\app.py"
echo.
echo Done. The app opens in the browser: http://127.0.0.1:8418/
echo Next time: the "Sifriya" shortcut on the desktop.
"%SystemRoot%\System32\timeout.exe" /t 8 >nul 2>nul
