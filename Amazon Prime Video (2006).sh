#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://www.amazon.com/video"

flatpak run org.chromium.Chromium --kiosk "$LINK"