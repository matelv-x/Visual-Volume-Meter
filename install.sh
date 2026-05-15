#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-/home/pi/sg1_v4/web/debug.htm}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPET="$SCRIPT_DIR/snippets/visual-volume-meter.html"
STATE_FILE="$SCRIPT_DIR/.last_backup_path"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="${TARGET}.bak-volume-meter-${STAMP}"
BEGIN_MARKER="<!-- BEGIN STARGATE VISUAL VOLUME METER ADD-ON -->"
END_MARKER="<!-- END STARGATE VISUAL VOLUME METER ADD-ON -->"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

[ -f "$TARGET" ] || fail "Target file not found: $TARGET"
[ -f "$SNIPPET" ] || fail "Snippet file not found: $SNIPPET"

cp -a "$TARGET" "$BACKUP"
echo "$BACKUP" > "$STATE_FILE"

TARGET_ENV="$TARGET" SNIPPET_ENV="$SNIPPET" BEGIN_ENV="$BEGIN_MARKER" END_ENV="$END_MARKER" python3 <<'PY'
from pathlib import Path
import os
import re

target = Path(os.environ["TARGET_ENV"])
snippet_path = Path(os.environ["SNIPPET_ENV"])
begin = os.environ["BEGIN_ENV"]
end = os.environ["END_ENV"]

html = target.read_text(encoding="utf-8", errors="replace")
snippet = snippet_path.read_text(encoding="utf-8")

pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.DOTALL)
if pattern.search(html):
    html = pattern.sub(snippet, html, count=1)
elif "</body>" in html:
    html = html.replace("</body>", snippet + "\n</body>", 1)
elif "</html>" in html:
    html = html.replace("</html>", snippet + "\n</html>", 1)
else:
    html = html.rstrip() + "\n\n" + snippet + "\n"

target.write_text(html, encoding="utf-8")
PY

echo "Visual Volume Meter installed in:"
echo "  $TARGET"
echo
echo "Backup created:"
echo "  $BACKUP"
echo
echo "Restart the Stargate service if needed:"
echo "  sudo systemctl restart stargate.service"
