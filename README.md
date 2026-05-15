# Stargate Visual Volume Meter Add-on

This repository contains a small Visual Volume Meter add-on for Jordan's original
StargateProject software.

It is an independent add-on package. It is not a fork of the original project and
does not replace the full StargateProject installation.

## Project Relationship

This add-on is intended to be used with:

1. Original StargateProject software:
   <https://github.com/jonnerd154/StargateProject-software>

2. This Visual Volume Meter add-on:
   <https://github.com/matelv-x/Visual-Volume-Meter>

The add-on targets the standard SG1_v4 web debug page:

```text
/home/pi/sg1_v4/web/debug.htm
```

## What It Adds

- a 20-segment visual volume meter
- low, mid, high, and max color zones
- animated pulse feedback when volume changes
- live volume polling from `stargate/get/system_info`
- volume up and volume down controls
- automatic refresh after volume button presses

## Included Files

```text
install.sh
restore.sh
snippets/visual-volume-meter.html
```

## Installation

Copy or clone this repository to the Raspberry Pi, then run:

```bash
cd /home/pi/Visual-Volume-Meter
chmod +x install.sh restore.sh
./install.sh
```

The installer modifies:

```text
/home/pi/sg1_v4/web/debug.htm
```

Before modifying the file, it creates a backup with a timestamp, for example:

```text
/home/pi/sg1_v4/web/debug.htm.bak-volume-meter-20260515_120000
```

The latest backup path is stored in:

```text
.last_backup_path
```

## Restore

To restore the previous `debug.htm` from the latest backup:

```bash
cd /home/pi/Visual-Volume-Meter
./restore.sh
sudo systemctl restart stargate.service
```

## Manual Installation

If you prefer to install manually, copy the contents of:

```text
snippets/visual-volume-meter.html
```

and insert it into:

```text
/home/pi/sg1_v4/web/debug.htm
```

The snippet includes the required `<style>`, HTML, and `<script>` blocks.

## Notes

- The web page must already load jQuery because the snippet uses `$` and
  `$.getJSON`.
- The StargateProject web API must expose `stargate/get/system_info`.
- The response should include `audio_volume`, for example `70%` or `70`.
- The add-on is safe to reinstall. The installer replaces its own marked block
  if it already exists.

## Safety Notice

Use this add-on at your own risk. Always keep a backup of your StargateProject
installation before modifying files on the Raspberry Pi.
