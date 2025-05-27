#!/bin/bash

. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://www.paramountplus.com/"

# Backup original dim timeout (ms)
ORIGINAL_TIMEOUT=$(kwriteconfig5 --file powermanagementprofilesrc \
  --group AC --group DPMSControl --key idleTime --get 2>/dev/null)

# Set screen dim to 30 minutes (1800000 ms)
kwriteconfig5 --file powermanagementprofilesrc \
  --group AC --group DPMSControl --key idleTime 1800000

# Apply the change immediately
qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement refreshProfile

# Launch Chromium and prevent system sleep while running
systemd-inhibit --what=handle-lid-switch:sleep \
--why="Watching Paramount Plus" \
flatpak run org.chromium.Chromium --kiosk "$LINK"

# Restore original screen dim timeout (if it was set)
if [[ -n "$ORIGINAL_TIMEOUT" ]]; then
  kwriteconfig5 --file powermanagementprofilesrc \
    --group AC --group DPMSControl --key idleTime "$ORIGINAL_TIMEOUT"
else
  # fallback default to 5 min (300000 ms) if original was unset
  kwriteconfig5 --file powermanagementprofilesrc \
    --group AC --group DPMSControl --key idleTime 300000
fi

# Apply the restoration
qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement refreshProfile
