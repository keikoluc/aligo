FROM node:18-bookworm-slim

WORKDIR /app

# better-sqlite3 falls back to compiling from source if no prebuilt binary
# matches this platform — these are node-gyp's build requirements.
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY admin-panel ./admin-panel
COPY miniapp ./miniapp

ENV NODE_ENV=production
EXPOSE 4000

CMD ["node", "src/server.js"]
