#!/usr/bin/env bash
# Deploy Cloudflare Gemini proxy + release build to connected iPhone.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NODE_BIN="${NODE_BIN:-$HOME/.local/node/bin}"
export PATH="$NODE_BIN:$PATH"

DEVICE_ID="${DEVICE_ID:-00008130-001A01610AA0001C}"
PROXY_URL="${GEMINI_PROXY_URL:-https://photo-coach-gemini-proxy.marsh-year.workers.dev/gemini}"

cd "$ROOT"

echo "==> Deploying Cloudflare Worker (temporary account)..."
npx wrangler deploy --temporary 2>&1 | tail -5

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo ""
  echo "WARNING: GEMINI_API_KEY not set. Cloud vision will fall back to on-device only."
  echo "Export your key: export GEMINI_API_KEY=your_key"
  echo ""
fi

echo "==> Building & installing on iPhone ($DEVICE_ID)..."
flutter run -d "$DEVICE_ID" --release \
  --dart-define=VISION_PROVIDER=proxy \
  --dart-define=GEMINI_PROXY_URL="$PROXY_URL" \
  ${GEMINI_API_KEY:+--dart-define=GEMINI_API_KEY=$GEMINI_API_KEY}