#!/bin/sh
# Linux / NAS launcher (run over SSH, e.g. on a QNAP/Synology box):
#   sh openCornField-docker.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but was not found. Install Docker / Container Station first."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but not reachable. Start the Docker service, then run this again."
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

echo "Starting CornField in Docker (the first build can take a few minutes)..."
docker compose up -d --build

echo ""
echo "CornField is starting. Open it from any device at:"
echo "  http://<this-server-ip>:${PORT}"
echo "In Settings, set Library Folder Path to /library, then click Scan Library."
echo "To stop it, run: docker compose down"
