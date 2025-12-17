#!/bin/bash

. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://www.discord.com/app"
CONFIG="$HOME/.config/powermanagementprofilesrc"
LOG="$HOME/stream_log.txt"
MAX_LOG_SIZE=307200   # 300 KB in bytes
TIMESTAMP=$(date)

rotate_log_if_needed() {
    [[ -f "$LOG" ]] || return

    local size
    size=$(stat -c%s "$LOG" 2>/dev/null || echo 0)

    if (( size > MAX_LOG_SIZE )); then
        # Keep only the last 75% of the log
        tail -c $((MAX_LOG_SIZE * 3 / 4)) "$LOG" > "${LOG}.tmp"
        mv "${LOG}.tmp" "$LOG"
        echo "[$(date)] Log trimmed to stay under 300KB" >> "$LOG"
    fi
}

# Helper: extract current value
extract_timeout() {
    awk -v section="$1" '
      $0=="["section"]" {found=1}
      found && /^idleTime=/ {print $2; exit}
      found && /^\[/ {exit}
    ' FS== "$CONFIG"
}

# Backup current timeouts
ORIGINAL_DPMS=$(extract_timeout "DPMSControl")
ORIGINAL_DIM=$(extract_timeout "DimDisplay")

cleanup() { # Restore original timeouts. 5 minutes default if not found.
    sed -i "/\[DPMSControl\]/,/^\[/ s/^idleTime=.*/idleTime=${ORIGINAL_DPMS:-300000}/" "$CONFIG"
    sed -i "/\[DimDisplay\]/,/^\[/ s/^idleTime=.*/idleTime=${ORIGINAL_DIM:-300000}/" "$CONFIG"
}
trap cleanup EXIT

# Rotate log if needed
rotate_log_if_needed

# Log original values
{
    echo "[$TIMESTAMP] Before launching Chromium"
    echo "DPMS Timeout: $ORIGINAL_DPMS"
    echo "DimDisplay Timeout: $ORIGINAL_DIM"
    echo ""
} >> "$LOG"

# Update timeouts to 30 min (1,800,000 ms)
sed -i "/\[DPMSControl\]/,/^\[/ s/^idleTime=.*/idleTime=1800000/" "$CONFIG"
sed -i "/\[DimDisplay\]/,/^\[/ s/^idleTime=.*/idleTime=1800000/" "$CONFIG"

# Log new values
{
    echo "[$(date)] After applying extended timeouts"
    echo "DPMS Timeout: $(extract_timeout "DPMSControl")"
    echo "DimDisplay Timeout: $(extract_timeout "DimDisplay")"
    echo ""
} >> "$LOG"

# Launch Chromium via systemd-inhibit without backgrounding
systemd-inhibit --what=handle-lid-switch:sleep --why="Using Discord" \
flatpak run org.chromium.Chromium --start-fullscreen --no-first-run --disable-session-crashed-bubble "$LINK"

# Final log
{
    echo "[$(date)] After Chromium closed - timeouts restored"
    echo "DPMS Timeout: $(extract_timeout "DPMSControl")"
    echo "DimDisplay Timeout: $(extract_timeout "DimDisplay")"
    echo "----------------------------------------------"
    echo ""
} >> "$LOG"
