# Stargate Visual Volume Meter Add-on

[![Downloads](https://img.shields.io/github/downloads/matelv-x/Visual-Volume-Meter/total?label=downloads)](https://github.com/matelv-x/Visual-Volume-Meter/releases)

Small Visual Volume Meter add-on for the StargateProject debug page.
https://github.com/jonnerd154/StargateProject-software

## Install

## Method 1 — GitHub Clone (Recommended)

```bash
cd /home/pi
rm -rf Visual-Volume-Meter
git clone https://github.com/matelv-x/Visual-Volume-Meter.git
cd Visual-Volume-Meter
chmod +x install.sh restore.sh
sudo ./install.sh
sudo systemctl restart stargate.service
```
## Method 2 — ZIP Download

1. Download and extract the ZIP archive into:

/home/pi/Visual-Volume-Meter

2. Then run:

```bash
cd /home/pi/Visual-Volume-Meter
chmod +x install.sh restore.sh
sudo ./install.sh
sudo systemctl restart stargate.service
```
## Restore / uninstall

```bash
cd /home/pi/Visual-Volume-Meter
sudo ./restore.sh
sudo systemctl restart stargate.service
```

## What it changes

<img width="666" height="212" alt="25%" src="https://github.com/user-attachments/assets/2f7d1a8f-37c0-426f-b7e1-7995df83ca6a" />
<img width="655" height="211" alt="100%" src="https://github.com/user-attachments/assets/092e86f0-fd19-4e66-b8bf-c644b2369e96" />

- Adds a 20-segment visual volume meter.
- Polls `stargate/get/system_info`.
- Patches `/home/pi/sg1_v4/web/debug.htm` only.

## Attribution and originality

Original base project: StargateProject SG1 software from the BuildAStargate/Jordan/Kristian/Jonnerd project lineage.

Additional source/idea credit: Feature idea by matelv-x/Codex over Jordan/Jonnerd StargateProject debug UI.

How much is copied or changed: Small self-contained HTML/JS/CSS snippet patch.
