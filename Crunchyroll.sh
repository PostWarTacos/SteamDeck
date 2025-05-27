#!/bin/bash
. "$HOME/.config/EmuDeck/backend/functions/all.sh"
source "$romsPath/cloud/cloud.conf"

LINK="https://www.crunchyroll.com/"

flatpak run org.chromium.Chromium --kiosk "$LINK"
