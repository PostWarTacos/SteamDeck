# SteamDeck Streaming Scripts

Launch streaming services in fullscreen Chromium on Steam Deck with extended timeout settings.

## Prerequisites

**Chromium Browser** is required for these scripts. The scripts will automatically check for Chromium and install it if not present.

To manually install Chromium:
```bash
flatpak install flathub org.chromium.Chromium
```

## Installation

1. **Place scripts in the cloud folder:**
   ```bash
   /home/deck/emulation/roms/cloud
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x /home/deck/emulation/roms/cloud/*.sh
   ```
   Or for individual scripts:
   ```bash
   chmod +x /home/deck/emulation/roms/cloud/Netflix.sh
   ```

## Usage

Run any script from the terminal or add them to your Steam library as non-Steam games. Each script will:
- Backup current display timeout settings
- Extend timeouts to 30 minutes while streaming
- Launch the streaming service in fullscreen Chromium
- Restore original timeout settings when closed (defaults to 5 minutes if unable to backup original settings)

## Steam Library Setup

To add these scripts to your Steam library:

1. In Steam, click **Games > Add a Non-Steam Game to My Library**
2. Configure the game with these settings:
   - **Target:** `/usr/bin/bash`
   - **Start In:** `/home/deck/emulation/roms/cloud`
   - **Launch Options:** `/home/deck/emulation/roms/cloud/<service>.sh`
     
     Example for Netflix: `/home/deck/emulation/roms/cloud/Netflix.sh`
3. Rename the game to match the service (e.g., "Netflix")
4. Use [SteamGridDB.com](https://www.steamgriddb.com) to find and download custom artwork for each service
5. Apply the artwork in Steam by right-clicking the game > Set Custom Artwork

## Available Services

- Amazon Prime Video
- Crunchyroll
- Discord
- Disney+
- Netflix
- Paramount+
- YouTube