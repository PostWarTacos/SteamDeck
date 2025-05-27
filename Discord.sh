#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://discord.com/app"

flatpak run org.chromium.Chromium --kiosk "$LINK"