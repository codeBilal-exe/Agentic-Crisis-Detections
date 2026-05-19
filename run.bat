@echo off
REM =====================================================================
REM CIRO - Crisis Intelligence and Response Orchestrator Launcher
REM National Emergency and Disaster Response System (Pakistan)
REM =====================================================================

title CIRO System Launcher
cd /d "%~dp0"

echo =====================================================================
echo        CIRO - CRISIS INTELLIGENCE ^& RESPONSE ORCHESTRATOR           
echo      Pakistan National Emergency ^& Disaster Response System         
echo =====================================================================
echo.

REM 1. Auto-Discover Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 call :discover_flutter

REM 2. Auto-Discover Python
set PYTHON_CMD=python
where python >nul 2>nul
if %errorlevel% neq 0 call :discover_python

REM 3. Setup Env File if Missing
if exist "signal_layer\.env" goto :env_ok
if not exist "signal_layer\.env.example" goto :env_ok
echo [+] Creating .env file from .env.example...
copy "signal_layer\.env.example" "signal_layer\.env" >nul
:env_ok

REM 4. Verify Python Before Starting Backend
%PYTHON_CMD% --version >nul 2>nul
if %errorlevel% equ 0 goto :python_ok
echo [ERROR] Python is not installed or the installation is broken on your system.
echo (e.g. Windows Apps redirect is active but Python was not found).
echo.
echo Please download and install Python 3.10+ (64-bit) from https://www.python.org/
echo and ensure you check the "Add python.exe to PATH" checkbox during setup.
echo.
pause
exit /b 1
:python_ok

REM 5. Start Signal Layer Backend (FastAPI Mock Server)
echo [+] Starting Signal Layer Backend Server...
start "CIRO Signal Server" cmd /k "cd /d "%~dp0signal_layer" && %PYTHON_CMD% -m uvicorn main:app --reload --port 8000"

REM 6. Pause briefly to allow backend to initialize
echo [+] Waiting 3 seconds for server to initialize...
ping -n 4 127.0.0.1 >nul

REM 7. Run Presentation Layer (Flutter App)
echo [+] Restoring Presentation Layer (Flutter) dependencies...
cd /d "%~dp0presentation_layer"
call flutter pub get
if %errorlevel% equ 0 goto :flutter_pub_ok
echo.
echo [ERROR] 'flutter pub get' failed. 
echo Please make sure Flutter is installed and accessible.
echo.
pause
exit /b %errorlevel%
:flutter_pub_ok

echo [+] Launching Presentation Layer on Chrome...
call flutter run -d chrome
if %errorlevel% equ 0 goto :flutter_run_ok
echo.
echo [WARNING] Failed to run Flutter app on Chrome. Trying default 'flutter run'...
call flutter run
:flutter_run_ok

pause
goto :eof

REM =====================================================================
REM SUBROUTINES
REM =====================================================================

:discover_flutter
set "FOUND_FLUTTER="
if exist "C:\FlutterDev\sdk\flutter\bin\flutter.bat" set "FOUND_FLUTTER=C:\FlutterDev\sdk\flutter\bin"
if exist "C:\flutter\bin\flutter.bat" set "FOUND_FLUTTER=C:\flutter\bin"
if exist "C:\src\flutter\bin\flutter.bat" set "FOUND_FLUTTER=C:\src\flutter\bin"
if exist "%USERPROFILE%\flutter\bin\flutter.bat" set "FOUND_FLUTTER=%USERPROFILE%\flutter\bin"
if exist "%USERPROFILE%\src\flutter\bin\flutter.bat" set "FOUND_FLUTTER=%USERPROFILE%\src\flutter\bin"
if exist "%USERPROFILE%\AppData\Local\Flutter\bin\flutter.bat" set "FOUND_FLUTTER=%USERPROFILE%\AppData\Local\Flutter\bin"

if "%FOUND_FLUTTER%"=="" goto :no_flutter_found
echo [+] Auto-discovered Flutter SDK at %FOUND_FLUTTER%.
echo [+] Adding to PATH temporarily...
set "PATH=%PATH%;%FOUND_FLUTTER%"
exit /b 0

:no_flutter_found
echo [WARNING] Flutter SDK was not found on your system PATH or standard folders.
exit /b 1

:discover_python
set "FOUND_PY="
if exist "C:\Python313\python.exe" set "FOUND_PY=C:\Python313"
if exist "C:\Python312\python.exe" set "FOUND_PY=C:\Python312"
if exist "C:\Python311\python.exe" set "FOUND_PY=C:\Python311"
if exist "C:\Python310\python.exe" set "FOUND_PY=C:\Python310"
if exist "C:\Python39\python.exe"  set "FOUND_PY=C:\Python39"

if exist "C:\Program Files\Python313\python.exe" set "FOUND_PY=C:\Program Files\Python313"
if exist "C:\Program Files\Python312\python.exe" set "FOUND_PY=C:\Program Files\Python312"
if exist "C:\Program Files\Python311\python.exe" set "FOUND_PY=C:\Program Files\Python311"
if exist "C:\Program Files\Python310\python.exe" set "FOUND_PY=C:\Program Files\Python310"
if exist "C:\Program Files\Python39\python.exe"  set "FOUND_PY=C:\Program Files\Python39"

if exist "C:\Program Files (x86)\Python313\python.exe" set "FOUND_PY=C:\Program Files (x86)\Python313"
if exist "C:\Program Files (x86)\Python312\python.exe" set "FOUND_PY=C:\Program Files (x86)\Python312"
if exist "C:\Program Files (x86)\Python311\python.exe" set "FOUND_PY=C:\Program Files (x86)\Python311"
if exist "C:\Program Files (x86)\Python310\python.exe" set "FOUND_PY=C:\Program Files (x86)\Python310"
if exist "C:\Program Files (x86)\Python39\python.exe"  set "FOUND_PY=C:\Program Files (x86)\Python39"

if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python313\python.exe" set "FOUND_PY=%USERPROFILE%\AppData\Local\Programs\Python\Python313"
if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" set "FOUND_PY=%USERPROFILE%\AppData\Local\Programs\Python\Python312"
if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python311\python.exe" set "FOUND_PY=%USERPROFILE%\AppData\Local\Programs\Python\Python311"
if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python310\python.exe" set "FOUND_PY=%USERPROFILE%\AppData\Local\Programs\Python\Python310"
if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python39\python.exe"  set "FOUND_PY=%USERPROFILE%\AppData\Local\Programs\Python\Python39"

if "%FOUND_PY%"=="" goto :no_python_found
echo [+] Auto-discovered Python at %FOUND_PY%.
echo [+] Adding to PATH temporarily...
set "PATH=%PATH%;%FOUND_PY%"
set PYTHON_CMD=python
exit /b 0

:no_python_found
:: Fallback check for 'py' launcher
where py >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON_CMD=py
    exit /b 0
)

:: Fallback check for 'python3' command
where python3 >nul 2>nul
if %errorlevel% equ 0 (
    set PYTHON_CMD=python3
    exit /b 0
)

exit /b 1
