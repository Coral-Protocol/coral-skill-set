#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <base_url> <auth_key> <namespace> <session_id> [timeout_seconds]" >&2
  exit 1
fi

BASE_URL="${1%/}"
AUTH_KEY="$2"
NAMESPACE="$3"
SESSION_ID="$4"
TIMEOUT_SECONDS="${5:-180}"

WS_BASE="${BASE_URL/http:\/\//ws://}"
WS_BASE="${WS_BASE/https:\/\//wss://}"
WS_URL="$WS_BASE/ws/v1/events/$AUTH_KEY/session/$NAMESPACE/$SESSION_ID"

python3 -u - "$WS_URL" "$TIMEOUT_SECONDS" <<'PY'
import asyncio
import json
import sys
import time

try:
    import websockets
except Exception as exc:
    print(f"websockets import failed: {exc}", flush=True)
    sys.exit(2)

ws_url = sys.argv[1]
timeout_seconds = int(sys.argv[2])

async def main():
    deadline = time.monotonic() + timeout_seconds
    async with websockets.connect(ws_url) as ws:
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                print("timeout without new thread_message_sent event", flush=True)
                return
            try:
                msg = await asyncio.wait_for(ws.recv(), timeout=remaining)
            except asyncio.TimeoutError:
                print("timeout without new thread_message_sent event", flush=True)
                return
            try:
                data = json.loads(msg)
            except Exception:
                continue
            if data.get("type") == "thread_message_sent":
                print("thread_message_sent", flush=True)
                return

asyncio.run(main())
PY
