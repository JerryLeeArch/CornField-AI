#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but was not found on this Mac."
  echo "Opening the Docker Desktop download page..."
  open "https://www.docker.com/products/docker-desktop/"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but not running. Please start Docker Desktop, then run this again."
  open -a Docker >/dev/null 2>&1 || true
  exit 1
fi

# First run: create the settings file and ask where your videos are.
if [ ! -f ".env" ]; then
  echo "First-time setup."
  cp .env.example .env
  printf "Enter the full path to your video library folder: "
  read -r LIBRARY_PATH
  if [ -z "$LIBRARY_PATH" ]; then
    echo "No folder entered. Edit .env and set CORNFIELD_LIBRARY_PATH, then run this again."
    rm -f .env
    exit 1
  fi
  grep -v -E '^CORNFIELD_LIBRARY_PATH=' .env > .env.tmp && mv .env.tmp .env
  printf 'CORNFIELD_LIBRARY_PATH=%s\n' "$LIBRARY_PATH" >> .env
fi

PORT="$(grep -E '^CORNFIELD_PORT=' .env | head -n1 | cut -d= -f2 | tr -d '[:space:]')"
PORT="${PORT:-4300}"
APP_URL="http://127.0.0.1:${PORT}"

echo "Starting CornField in Docker (the first build can take a few minutes)..."
docker compose up -d --build

READY=0
for _ in $(seq 1 120); do
  if curl -fsS "$APP_URL" >/dev/null 2>&1; then
    READY=1
    break
  fi
  sleep 0.5
done

if [ "$READY" -eq 1 ]; then
  open "$APP_URL"
  echo "CornField is running at $APP_URL"
else
  echo "CornField is still starting. Open $APP_URL in your browser shortly."
fi

echo "It keeps running in the background. To stop it, run: docker compose down"
