@echo off
setlocal enabledelayedexpansion

set "PORT=%~1"
if "%PORT%"=="" set "PORT=8000"

set "DIR=%~dp0"
cd /d "%DIR%"

where python >nul 2>nul
if %errorlevel%==0 (
    set "PY=python"
) else (
    where py >nul 2>nul
    if !errorlevel!==0 (
        set "PY=py"
    ) else (
        echo Python is required but was not found in PATH.
        exit /b 1
    )
)

set "LAN_IP="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    if not defined LAN_IP (
        set "IP=%%A"
        set "LAN_IP=!IP: =!"
    )
)

set "LOCAL_URL=http://localhost:%PORT%/index.html"

echo Starting server on port %PORT%...
echo Local:   %LOCAL_URL%
if defined LAN_IP (
    set "NETWORK_URL=http://!LAN_IP!:%PORT%/index.html"
    echo Network: !NETWORK_URL!
)
echo.
echo Press Ctrl+C to stop.

start "" /b cmd /c "timeout /t 1 >nul & start "" "%LOCAL_URL%""

%PY% -m http.server %PORT% --bind 0.0.0.0
