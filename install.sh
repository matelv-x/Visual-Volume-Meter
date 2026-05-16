#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-/home/pi/sg1_v4/web/debug.htm}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPET="${SCRIPT_DIR}/snippets/visual-volume-meter.html"
STATE_FILE="${SCRIPT_DIR}/.last_backup_path"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="${TARGET}.bak-volume-meter-${STAMP}"
BEGIN_MARKER="<!-- BEGIN STARGATE VISUAL VOLUME METER ADD-ON -->"
END_MARKER="<!-- END STARGATE VISUAL VOLUME METER ADD-ON -->"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

[ -f "$TARGET" ] || fail "Target file not found: $TARGET"

SNIPPET_SOURCE="file"
if [ ! -f "$SNIPPET" ]; then
  SNIPPET_SOURCE="embedded"
fi

cp -a "$TARGET" "$BACKUP"
echo "$BACKUP" > "$STATE_FILE"

TARGET_ENV="$TARGET" SNIPPET_ENV="$SNIPPET" SNIPPET_SOURCE_ENV="$SNIPPET_SOURCE" INSTALLER_ENV="$0" BEGIN_ENV="$BEGIN_MARKER" END_ENV="$END_MARKER" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

target = Path(os.environ["TARGET_ENV"])
snippet_path = Path(os.environ["SNIPPET_ENV"])
snippet_source = os.environ["SNIPPET_SOURCE_ENV"]
installer = Path(os.environ["INSTALLER_ENV"])
begin = os.environ["BEGIN_ENV"]
end = os.environ["END_ENV"]
embedded_begin = "__VISUAL_VOLUME_METER_SNIPPET_BEGIN__"
embedded_end = "__VISUAL_VOLUME_METER_SNIPPET_END__"

html = target.read_text(encoding="utf-8", errors="replace")

if snippet_source == "file":
    snippet = snippet_path.read_text(encoding="utf-8")
else:
    installer_text = installer.read_text(encoding="utf-8", errors="replace")
    start = installer_text.rfind(embedded_begin)
    stop = installer_text.rfind(embedded_end)
    if start == -1 or stop == -1 or stop <= start:
        print("ERROR: Embedded snippet not found in install.sh", file=sys.stderr)
        sys.exit(1)
    snippet = installer_text[start + len(embedded_begin):stop].strip("\n")

pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.DOTALL)
html = pattern.sub("", html)

volume_up_button = re.compile(
    r'(<button\b[^>]*\baction=["\']volume_up["\'][^>]*>.*?</button>)',
    re.IGNORECASE | re.DOTALL,
)
match = volume_up_button.search(html)
if match:
    insert_at = match.end()
    html = html[:insert_at] + "\n" + snippet + html[insert_at:]
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
echo "Snippet source:"
echo "  $SNIPPET_SOURCE"
echo
echo "Backup created:"
echo "  $BACKUP"
echo
echo "Restart the Stargate service if needed:"
echo "  sudo systemctl restart stargate.service"

exit 0

: <<'__VISUAL_VOLUME_METER_EMBEDDED_BLOCK__'
__VISUAL_VOLUME_METER_SNIPPET_BEGIN__
<!-- BEGIN STARGATE VISUAL VOLUME METER ADD-ON -->
<style>
  .volume-meter-wrap {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .volume-meter-panel {
    display: flex;
    flex-direction: column;
    gap: 6px;
    width: auto;
    align-items: flex-start;
  }

  .volume-meter-shell {
    padding: 0;
    width: auto;
    margin-left: 14px;
  }

  .volume-meter {
    display: flex;
    flex-wrap: nowrap;
    gap: 3px;
    align-items: center;
    justify-content: flex-start;
    width: auto;
    min-height: 26px;
  }

  .volume-seg {
    width: 10px;
    min-width: 10px;
    height: 20px;
    border-radius: 2px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.10);
    box-sizing: border-box;
    opacity: 0.18;
    transition: opacity 0.14s ease, transform 0.14s ease, box-shadow 0.14s ease, filter 0.14s ease, background 0.14s ease, border-color 0.14s ease;
  }

  .volume-seg.on {
    opacity: 1;
  }

  .volume-seg.on.tone-low {
    background: linear-gradient(to bottom, #ffe975 0%, #ffd43b 100%);
    border-color: rgba(255, 229, 116, 0.95);
    box-shadow: 0 0 8px rgba(255, 212, 59, 0.65), 0 0 18px rgba(255, 212, 59, 0.28);
  }

  .volume-seg.on.tone-mid {
    background: linear-gradient(to bottom, #ffb85a 0%, #ff9322 100%);
    border-color: rgba(255, 177, 89, 0.95);
    box-shadow: 0 0 8px rgba(255, 147, 34, 0.68), 0 0 18px rgba(255, 147, 34, 0.30);
  }

  .volume-seg.on.tone-high {
    background: linear-gradient(to bottom, #ff6f3d 0%, #ff4c10 100%);
    border-color: rgba(255, 122, 76, 0.95);
    box-shadow: 0 0 10px rgba(255, 76, 16, 0.70), 0 0 20px rgba(255, 76, 16, 0.34);
  }

  .volume-seg.on.tone-max {
    background: linear-gradient(to bottom, #a11414 0%, #4b0000 100%);
    border-color: rgba(166, 46, 46, 0.95);
    box-shadow: 0 0 10px rgba(139, 0, 0, 0.68), 0 0 20px rgba(139, 0, 0, 0.30);
  }

  .volume-seg.pulse {
    animation: volumePulse 0.28s ease-out;
  }

  @keyframes volumePulse {
    0% { transform: scale(1); filter: brightness(1); }
    35% { transform: scale(1.08); filter: brightness(1.32); }
    100% { transform: scale(1); filter: brightness(1); }
  }

  .volume-meter-footer {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    width: auto;
  }

  .volume-meter-label {
    font-size: 12px;
    color: #ffffff;
    user-select: none;
    text-align: right;
    letter-spacing: 0.5px;
  }
</style>
<div class="volume-meter-wrap">
  <div class="volume-meter-panel">
    <div class="volume-meter-shell">
      <div id="volumeMeter" class="volume-meter"></div>
    </div>

    <div class="volume-meter-footer">
      <div id="volumeMeterLabel" class="volume-meter-label">VOL 0%</div>
    </div>
  </div>
</div>
<script type="text/javascript">
  var lastVolumePercent = null;
  var volumePollInterval = null;
  var volumeActionInProgress = false;
  var volumeRefreshToken = 0;
  var TOTAL_SEGMENTS = 20;

  function parseAudioVolume(rawValue) {
    if (rawValue === undefined || rawValue === null) return null;
    if (typeof rawValue === "number") return Math.max(0, Math.min(100, rawValue));

    var text = String(rawValue).trim();
    var match = text.match(/(\d+)/);
    if (!match) return null;

    var parsed = parseInt(match[1], 10);
    if (isNaN(parsed)) return null;

    return Math.max(0, Math.min(100, parsed));
  }

  function getToneClassByIndex(index) {
    if (index < 5) return 'tone-low';
    if (index < 10) return 'tone-mid';
    if (index < 15) return 'tone-high';
    return 'tone-max';
  }

  function buildVolumeMeter() {
    var meter = document.getElementById('volumeMeter');
    if (!meter) return;

    meter.innerHTML = '';

    for (var i = 0; i < TOTAL_SEGMENTS; i++) {
      var seg = document.createElement('div');
      seg.className = 'volume-seg';
      seg.setAttribute('data-index', i);
      seg.setAttribute('data-tone', getToneClassByIndex(i));
      meter.appendChild(seg);
    }
  }

  function drawVolumeMeter(percent, previousPercent) {
    var segs = document.querySelectorAll('#volumeMeter .volume-seg');
    if (!segs.length) return;

    var lit = Math.round((percent / 100) * TOTAL_SEGMENTS);
    lit = Math.max(0, Math.min(TOTAL_SEGMENTS, lit));

    var prevLit = null;
    if (previousPercent !== null && previousPercent !== undefined) {
      prevLit = Math.round((previousPercent / 100) * TOTAL_SEGMENTS);
      prevLit = Math.max(0, Math.min(TOTAL_SEGMENTS, prevLit));
    }

    segs.forEach(function(seg, idx) {
      seg.classList.remove('on', 'pulse', 'tone-low', 'tone-mid', 'tone-high', 'tone-max');

      if (idx < lit) {
        seg.classList.add('on');
        seg.classList.add(seg.getAttribute('data-tone'));
      }
    });

    if (prevLit !== null && prevLit !== lit) {
      if (lit > prevLit && lit > 0) {
        segs[lit - 1].classList.add('pulse');
      } else if (lit < prevLit && lit < segs.length) {
        segs[Math.max(0, lit)].classList.add('pulse');
      }
    }

    $('#volumeMeterLabel').text('VOL ' + percent + '%');
  }

  function refreshRealVolumeMeter(options) {
    options = options || {};
    var force = !!options.force;

    if (volumeActionInProgress && !force) return;

    var requestToken = ++volumeRefreshToken;

    $.getJSON('stargate/get/system_info')
      .done(function(data) {
        if (requestToken !== volumeRefreshToken) return;

        var percent = parseAudioVolume(data.audio_volume);
        if (percent === null) return;

        drawVolumeMeter(percent, lastVolumePercent);
        lastVolumePercent = percent;
      });
  }

  function pauseVolumePolling() {
    if (volumePollInterval) {
      clearInterval(volumePollInterval);
      volumePollInterval = null;
    }
  }

  function resumeVolumePolling() {
    pauseVolumePolling();
    volumePollInterval = setInterval(function() {
      refreshRealVolumeMeter();
    }, 2500);
  }

  function runVolumeSyncSequence() {
    var delays = [90, 180, 300, 460];
    var stepIndex = 0;

    function nextStep() {
      if (stepIndex >= delays.length) {
        volumeActionInProgress = false;
        refreshRealVolumeMeter({ force: true });
        resumeVolumePolling();
        return;
      }

      setTimeout(function() {
        refreshRealVolumeMeter({ force: true });
        stepIndex++;
        nextStep();
      }, delays[stepIndex]);
    }

    nextStep();
  }

  function initialize_real_volume_meter() {
    buildVolumeMeter();
    drawVolumeMeter(0, null);
    refreshRealVolumeMeter({ force: true });
    resumeVolumePolling();

    $('button[action="volume_up"], button[action="volume_down"]')
      .off('click.volumeMeter')
      .on('click.volumeMeter', function() {
        pauseVolumePolling();

        if (volumeActionInProgress) return;

        volumeActionInProgress = true;
        runVolumeSyncSequence();
      });
  }

  $(function() {
    initialize_real_volume_meter();

    $('button[action="volume_up"]').click(function() {
      var next = Math.min(100, (lastVolumePercent || 0) + 5);

      drawVolumeMeter(
        next,
        lastVolumePercent
      );

      lastVolumePercent = next;
    });

    $('button[action="volume_down"]').click(function() {
      var next = Math.max(0, (lastVolumePercent || 0) - 5);

      drawVolumeMeter(
        next,
        lastVolumePercent
      );

      lastVolumePercent = next;
    });
  });
</script>
<!-- END STARGATE VISUAL VOLUME METER ADD-ON -->
__VISUAL_VOLUME_METER_SNIPPET_END__
__VISUAL_VOLUME_METER_EMBEDDED_BLOCK__
