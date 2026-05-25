# Stargate Visual Volume Meter Add-on

Small Visual Volume Meter add-on for the StargateProject debug page.

This repository is private while it is being checked and verified.

## Install

Clone or unzip this add-on into `/home/pi`, then run:

```bash
cd /home/pi
rm -rf Visual-Volume-Meter
git clone https://github.com/matelv-x/Visual-Volume-Meter.git
cd Visual-Volume-Meter
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

- Adds a 20-segment visual volume meter.
- Polls `stargate/get/system_info`.
- Patches `/home/pi/sg1_v4/web/debug.htm` only.

## Attribution and originality

Original base project: StargateProject SG1 software from the BuildAStargate/Jordan/Kristian/Jonnerd project lineage.

Additional source/idea credit: Feature idea by matelv-x/Codex over Jordan/Jonnerd StargateProject debug UI.

How much is copied or changed: Small self-contained HTML/JS/CSS snippet patch.
