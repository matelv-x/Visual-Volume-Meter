#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-/home/pi/sg1_v4/web/debug.htm}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/.last_backup_path"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

if [ -f "$STATE_FILE" ]; then
  BACKUP="$(cat "$STATE_FILE")"
else
  BACKUP="$(ls -dt "${TARGET}".bak-volume-meter-* 2>/dev/null | head -n 1 || true)"
fi

[ -n "${BACKUP:-}" ] || fail "No backup path found"
[ -f "$BACKUP" ] || fail "Backup file does not exist: $BACKUP"

cp -a "$BACKUP" "$TARGET"

echo "Restored:"
echo "  $TARGET"
echo
echo "From backup:"
echo "  $BACKUP"
