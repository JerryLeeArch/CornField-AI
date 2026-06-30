# CornField

CornField is a video player app for your personal libraries.
While CornField keeps your original files on disk untouched, it stores app data locally, and gives you a fast browser UI for browsing, tagging, rating, and watching your own video.

No sample media is bundled in this repository. You point CornField at your own video folder on first use.

## Choose how to run

CornField is a single web server you open in a browser. Pick the setup that matches you:

|                      | Option 1 — Your computer          | Option 2 — NAS / home server                  |
| -------------------- | --------------------------------- | --------------------------------------------- |
| Best for             | Single device usage               | One library/DB shared across all your devices |
| How you run it       | simply click `openCornField` file | `docker compose up -d`                        |
| Where data lives     | Project `data/` folder            | A folder you mount (e.g. on the NAS)          |
| URL after the launch | `http://localhost:4300`           | `http://<server-ip>:4300` from any device     |

## Option 1 — Run on your computer

1. Get the code:

```bash
git clone <repo-url>
cd CornField
```

2. Start it:
   - macOS: double-click `openCornField.command` (if the first launch is blocked, allow it in `System Settings > Privacy & Security > Open Anyway`)
   - Windows: double-click `openCornField.cmd`
   - Any OS (manual): `npm install && npm run dev`

   The desktop launchers open the Node.js download page if Node is missing, install dependencies on first run, start the server, and open your browser.

3. Open [http://localhost:4300](http://localhost:4300), then follow [First-Time Setup](#first-time-setup).

Your database and thumbnails are stored in the project's `data/` folder.

## Option 2 — Run on a NAS / home server

Run CornField once on an always-on machine (like a QNAP/Synology NAS with Docker). Then every
device in your home just opens it in a browser — same videos, same data, everywhere. It works
on NAS hardware, including low-power `arm64` models. You only need Docker installed.

1. Download the code:

```bash
git clone <repo-url>
cd CornField
```

2. Start the launcher for your system:
   - macOS: double-click `openCornField-docker.command`
   - Windows: double-click `openCornField-docker.cmd`
   - NAS / Linux (over SSH): `sh openCornField-docker.sh`

   The first time, it asks for the folder that holds your videos, then builds and starts
   everything for you. (The first build can take a few minutes.)

3. On any device, open `http://<server-ip>:4300` (or `http://localhost:4300` if it's this
   computer), then follow [First-Time Setup](#first-time-setup) using `/library` as the path.

To stop it later, run `docker compose down`. To update, run `git pull` and start the launcher again.

Good to know:

- Your settings are saved in a `.env` file that stays on your machine, so updating with `git pull` never overwrites them.
- The first scan can be slow on small NAS boxes because it makes a thumbnail for every video. Everyday browsing afterward is fast.

## First-Time Setup

Once CornField is open in your browser:

1. Open `Settings`.
2. Set `Library Folder Path` to your videos folder (use `/library` if you started with Docker / Option 2).
3. Click `Scan Library`.

## Scan Behavior

When you click `Scan Library`, CornField:

- Adds new videos it finds in your library folder
- Removes videos whose files you have deleted
- Creates a thumbnail automatically for each new video

## Features

- Browse, search, and play your videos in the browser
- Organize with titles, descriptions, categories, tags, and starring
- Rate videos, leave comments, and add jump markers("corns") at specific moments
- See related videos based on shared tags and categories
- Automatic thumbnails, or upload/capture your own
- Hover the seek bar to preview scenes, plus keyboard shortcuts for playback

## Technical Notes

### Local Data

- Your media files stay in their original folders and are not copied by default.
- App data is stored in `data/videoplayer.db`.
- Generated or uploaded thumbnails are stored in `data/thumbnails/`.
- Seek-bar hover previews are cached in `data/timeline-previews/` on demand.
- `data/` is gitignored so your personal library state does not get committed to GitHub.
- In Docker, this folder is whatever you set as `CORNFIELD_DATA_PATH`. Keep it on the server's own local disk (not a network/SMB/NFS share) so SQLite file locking stays reliable.

### Tech Stack

- Backend: Node.js + Fastify
- Database: SQLite (`better-sqlite3`)
- Frontend: Vanilla HTML/CSS/JavaScript
- Media probing: `ffprobe` (bundled `ffprobe-static`, or system `ffprobe` on `arm64`/Docker)
- Thumbnail extraction for auto-capture: `ffmpeg` when available

### Project Structure

- `src/server.js`: Fastify API, streaming, file operations
- `src/db.js`: SQLite schema, settings, relation helpers
- `src/media-indexer.js`: folder scan, probe, sync, auto-thumbnail logic
- `openCornField.command` / `openCornField.cmd`: macOS / Windows launchers (run on your computer)
- `openCornField-docker.command` / `.cmd` / `.sh`: macOS / Windows / Linux-NAS launchers (Docker)
- `public/index.html`: app shell
- `public/app.js`: UI behavior and API integration
- `public/styles.css`: dark theme styling
- `Dockerfile`, `docker-compose.yml`, `.env.example`: NAS / server deployment

### API Overview

- `GET /api/settings`, `PUT /api/settings`
- `POST /api/library/scan/preview`, `POST /api/library/scan`
- `GET /api/videos`, `GET /api/videos/admin`, `GET /api/videos/:id`
- `PUT /api/videos/:id/metadata`
- `POST /api/videos/:id/rename`
- `DELETE /api/videos/:id`
- `POST /api/videos/:id/view`
- `GET|POST /api/videos/:id/comments`, `PUT|DELETE /api/comments/:id`
- `GET|POST /api/videos/:id/notes`, `PUT|DELETE /api/notes/:id`
- `POST /api/videos/:id/thumbnail/upload`
- `POST /api/videos/:id/thumbnail/capture`
- `GET /api/videos/:id/previews`
- `GET /api/videos/:id/related`
- `GET /api/tags`, `GET /api/starrings`
- `GET /media/*` (video streaming)
