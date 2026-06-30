@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

where docker >nul 2>nul
if errorlevel 1 (
  echo Docker is required but was not found on this PC.
  echo Opening the Docker Desktop download page...
  start "" "https://www.docker.com/products/docker-desktop/"
  exit /b 1
)

docker info >nul 2>nul
if errorlevel 1 (
  echo Docker is installed but not running. Please start Docker Desktop, then run this again.
  exit /b 1
)

if not exist ".env" (
  echo First-time setup.
  copy /y ".env.example" ".env" >nul
  set /p "LIBRARY_PATH=Enter the full path to your video library folder: "
  if "!LIBRARY_PATH!"=="" (
    echo No folder entered. Edit .env and set CORNFIELD_LIBRARY_PATH, then run this again.
    del ".env"
    exit /b 1
  )
  findstr /v /b "CORNFIELD_LIBRARY_PATH=" ".env" > ".env.tmp"
  move /y ".env.tmp" ".env" >nul
  echo CORNFIELD_LIBRARY_PATH=!LIBRARY_PATH!>> ".env"
)

set "PORT=4300"
for /f "tokens=2 delims==" %%a in ('findstr /b "CORNFIELD_PORT=" ".env"') do set "PORT=%%a"
set "APP_URL=http://127.0.0.1:%PORT%"

echo Starting CornField in Docker (the first build can take a few minutes)...
docker compose up -d --build
if errorlevel 1 exit /b 1

start "" /min powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$url = '%APP_URL%'; for ($i = 0; $i -lt 120; $i++) { try { Invoke-WebRequest -Uri $url -UseBasicParsing | Out-Null; Start-Process $url; exit 0 } catch { Start-Sleep -Milliseconds 500 } }; Start-Process $url"

echo CornField is starting at %APP_URL%
echo It keeps running in the background. To stop it, run: docker compose down
