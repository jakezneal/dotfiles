#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# macOS Tahoe "strict" setup defaults (UI-focused, low-risk)
###############################################################################

sudo -v || true

CURRENT_USER="$(/usr/bin/stat -f%Su /dev/console)"
CURRENT_UID="$(/usr/bin/id -u "$CURRENT_USER")"

as_user() {
  /bin/launchctl asuser "$CURRENT_UID" sudo -u "$CURRENT_USER" "$@"
}

###############################################################################
# General UI/UX
###############################################################################

as_user defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
as_user defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
as_user defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
as_user defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
as_user defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
as_user defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
as_user defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Dark Mode (best-effort)
as_user /usr/bin/osascript -e \
  'tell application "System Events" to tell appearance preferences to set dark mode to true' || true

###############################################################################
# Dock / Desktop & Dock
###############################################################################

# Turn off "Show suggested and recent apps in Dock"
as_user defaults write com.apple.dock show-recents -bool false || true

# "Click wallpaper to show desktop" -> "Only in Stage Manager"
# Always=1, Only in Stage Manager=0
as_user defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0 || true

###############################################################################
# Control Center / Menu Bar (modern)
###############################################################################

# Show Bluetooth/Sound in menu bar (keep if you want them visible)
as_user defaults -currentHost write com.apple.controlcenter Bluetooth -int 18
as_user defaults -currentHost write com.apple.controlcenter Sound -int 18
as_user defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# Remove Wi-Fi from menu bar
as_user defaults -currentHost write com.apple.controlcenter WiFi -int 24 || true

# Remove Spotlight from menu bar
as_user defaults -currentHost write com.apple.controlcenter Spotlight -int 24 || true

###############################################################################
# Default browser: Arc
###############################################################################
# Sets default handler for http/https to Arc via LaunchServices.
# Arc bundle id: company.thebrowser.Browser
set_default_browser_bundleid() {
  local bundle_id="$1"
  local ls_plist="${HOME}/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"

  if [[ ! -f "$ls_plist" ]]; then
    # Ensure directory exists; plist will be created by LS over time, but we can create it.
    mkdir -p "$(dirname "$ls_plist")"
    /usr/bin/plutil -create binary1 "$ls_plist" 2>/dev/null || true
  fi

  /usr/bin/python3 - <<'PY' "$ls_plist" "$bundle_id"
import sys, plistlib, os

path = sys.argv[1]
bundle = sys.argv[2]

data = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    with open(path, "rb") as f:
        try:
            data = plistlib.load(f)
        except Exception:
            data = {}

handlers = data.get("LSHandlers", [])
def upsert(urlscheme):
    # Remove existing entries for scheme so we don't accumulate duplicates
    new_handlers = []
    found = False
    for h in handlers:
        if h.get("LSHandlerURLScheme") == urlscheme:
            found = True
            # Replace with Arc
            continue
        new_handlers.append(h)
    # Add Arc handler
    new_handlers.append({
        "LSHandlerURLScheme": urlscheme,
        "LSHandlerRoleAll": bundle
    })
    return new_handlers

handlers = upsert("http")
handlers = upsert("https")

data["LSHandlers"] = handlers
with open(path, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)
PY
}

# Only attempt if Arc is installed
if [[ -d "/Applications/Arc.app" ]]; then
  as_user bash -lc 'set_default_browser_bundleid company.thebrowser.Browser' 2>/dev/null || {
    # If function scope isn't exported, call it in current shell:
    set_default_browser_bundleid company.thebrowser.Browser || true
  }
else
  echo "Arc.app not found in /Applications; skipping default browser change."
fi

###############################################################################
# Lock Screen: display sleep timers (battery / power adapter)
###############################################################################
# "Turn display off on battery when inactive" -> 5 minutes
sudo /usr/bin/pmset -b displaysleep 5

# "Turn display off on power adapter when inactive" -> 30 minutes
sudo /usr/bin/pmset -c displaysleep 30

###############################################################################
# Displays: turn off "Automatically adjust brightness"
###############################################################################
# Works on Macs with an ambient light sensor; harmless if key is ignored.
sudo /usr/bin/defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false || true

###############################################################################
# Spotlight shortcuts: disable
# - "Show Spotlight search" (Cmd+Space) => symbolic hotkey 64
# - "Show Finder search window" (Option+Cmd+Space) => symbolic hotkey 65
###############################################################################
disable_symbolic_hotkey() {
  local id="$1"
  local plist="${HOME}/Library/Preferences/com.apple.symbolichotkeys.plist"

  /usr/bin/python3 - <<'PY' "$plist" "$id"
import sys, plistlib, os

path = sys.argv[1]
hotkey_id = str(int(sys.argv[2]))

data = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    with open(path, "rb") as f:
        try:
            data = plistlib.load(f)
        except Exception:
            data = {}

ashk = data.get("AppleSymbolicHotKeys", {})
entry = ashk.get(hotkey_id, {})

# Preserve existing value dict, just disable.
entry["enabled"] = False
ashk[hotkey_id] = entry
data["AppleSymbolicHotKeys"] = ashk

with open(path, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)
PY
}

as_user bash -lc 'disable_symbolic_hotkey 64; disable_symbolic_hotkey 65' 2>/dev/null || {
  disable_symbolic_hotkey 64 || true
  disable_symbolic_hotkey 65 || true
}

###############################################################################
# Restart affected UI services
###############################################################################
killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
killall cfprefsd >/dev/null 2>&1 || true

echo "Done. Some changes may require logout/restart to fully apply."
