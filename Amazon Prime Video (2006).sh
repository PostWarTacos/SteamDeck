#!/bin/bash

. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://www.amazon.com/video"
CONFIG="$HOME/.config/powermanagementprofilesrc"
LOG="$HOME/stream_log.txt"
TIMESTAMP=$(date)

# Helper: extract current value
extract_timeout() {
    grep -A1 "\[$1\]" "$CONFIG" | grep idleTime | cut -d= -f2 | tr -d ' '
}

# Backup current timeouts
ORIGINAL_DPMS=$(extract_timeout "DPMSControl")
ORIGINAL_DIM=$(extract_timeout "DimDisplay")

# Log original values
{
    echo "[$TIMESTAMP] 🔍 Before launching Chromium"
    echo "DPMS Timeout: $ORIGINAL_DPMS"
    echo "DimDisplay Timeout: $ORIGINAL_DIM"
    echo ""
} >> "$LOG"

# Launch Chromium via systemd-inhibit without backgrounding
systemd-inhibit --what=handle-lid-switch:sleep --why="Watching Amazon Prime" \
flatpak run org.chromium.Chromium --kiosk "$LINK" &

# Grab the Chromium process
sleep 3  # Let it launch
CHROME_PID=$(pgrep -f "org.chromium.Chromium.*--kiosk" | head -n1)

# Update timeouts to 30 min (1800000 ms)
sed -i "/\[DPMSControl\]/,/^\[/ s/^idleTime=.*/idleTime=1800000/" "$CONFIG"
sed -i "/\[DimDisplay\]/,/^\[/ s/^idleTime=.*/idleTime=1800000/" "$CONFIG"

# Log new values
{
    echo "[$(date)] ✅ After applying extended timeouts"
    echo "DPMS Timeout: $(extract_timeout "DPMSControl")"
    echo "DimDisplay Timeout: $(extract_timeout "DimDisplay")"
    echo ""
} >> "$LOG"

# Wait for Chromium to exit
#wait

# Wait for the real Chromium process to close
while kill -0 "$CHROME_PID" 2>/dev/null; do
    sleep 2
done

# Restore original values
sed -i "/\[DPMSControl\]/,/^\[/ s/^idleTime=.*/idleTime=${ORIGINAL_DPMS:-300000}/" "$CONFIG"
sed -i "/\[DimDisplay\]/,/^\[/ s/^idleTime=.*/idleTime=${ORIGINAL_DIM:-300000}/" "$CONFIG"

# Final log
{
    echo "[$(date)] 🔄 After Chromium closed – timeouts restored"
    echo "DPMS Timeout: $(extract_timeout "DPMSControl")"
    echo "DimDisplay Timeout: $(extract_timeout "DimDisplay")"
    echo "----------------------------------------------"
    echo ""
} >> "$LOG"
