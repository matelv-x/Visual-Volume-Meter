# Visual Volume Meter

Adds a live segmented volume meter to the StargateProject debug page.

This repository is private while it is being checked and verified.

## Install

```bash
cd /home/pi/Stargate-Final_Patches
rm -rf Visual-Volume-Meter
git clone https://github.com/matelv-x/Visual-Volume-Meter.git
cd Visual-Volume-Meter
chmod +x *.sh
sudo ./install.sh /home/pi/sg1_v4
sudo systemctl restart stargate.service
```

## Restore / uninstall

```bash
cd /home/pi/Stargate-Final_Patches/Visual-Volume-Meter
chmod +x restore.sh
sudo ./restore.sh /home/pi/sg1_v4
sudo systemctl restart stargate.service
```

## What it changes

- Adds a visual volume meter under Sound & Volume on debug.htm.
- Reads audio_volume from the Stargate system info API.
- Refreshes the meter after Volume Up and Volume Down actions.

## Attribution and originality

Original base project: StargateProject SG1 software from the BuildAStargate/Jordan/Kristian/Jonnerd project lineage.

Additional source/idea credit: Idea and feature layer by Marcin/Codex, implemented as a patch over Jordan/Kristian/Jonnerd StargateProject SG1 web/debug files.

How much is copied or changed: Small patch/overlay. It copies selected modified debug web files and a patch file; it is not a full copy of the base project.

The included `*.patch` file, when present, shows the exact text-level changes against the base software used while packaging.
