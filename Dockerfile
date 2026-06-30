# CornField — pure serving image (Node + SQLite + ffmpeg)
# Builds natively for the host architecture, including arm64 (e.g. QNAP TS-233).
FROM node:22-bookworm-slim

# ffprobe-static ships no linux/arm64 binary, so install system ffmpeg/ffprobe.
# The app prefers FFMPEG_PATH/FFPROBE_PATH, then bundled statics, then PATH.
RUN apt-get update \
  && apt-get install -y --no-install-recommends ffmpeg ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=4300 \
    FFMPEG_PATH=/usr/bin/ffmpeg \
    FFPROBE_PATH=/usr/bin/ffprobe

WORKDIR /app

# Install dependencies first for better layer caching.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Application source.
COPY src ./src
COPY public ./public

# CornField keeps its DB, thumbnails, and seek previews under /app/data.
# Mount a host/NAS folder over this path to persist and share across devices.
RUN mkdir -p data/thumbnails data/timeline-previews
VOLUME ["/app/data"]

EXPOSE 4300

CMD ["node", "src/server.js"]
