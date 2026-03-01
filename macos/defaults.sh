#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# macOS Tahoe setup defaults (Core + Extended + optional Risky/System)
#
# Goals:
# - CORE: stable, per-user UI defaults that tend to keep working across macOS.
# - EXTENDED: extra UI polish and “nice to have” app prefs (still low-risk),
#             but more likely to drift across versions.
# - RISKY/SYSTEM: system-wide or side-effect-prone tweaks (OFF by default).
#
# Usage:
#   ./defaults.sh                 # CORE + EXTENDED
#   ./defaults.sh --core-only     # CORE only
#   ./defaults.sh --risk          # CORE + EXTENDED + RISKY/SYSTEM
#   ./defaults.sh --no-extended   # CORE only (same as --core-only)
#   ./defaults.sh --dry-run       # print what would run
###############################################################################

CORE=1
EXTENDED=1
RISK=0
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        --core-only|--no-extended) EXTENDED=0 ;;
        --extended) EXTENDED=1 ;;
        --risk|--enable-risky) RISK=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            sed -n '1,80p' "$0"
            exit 0
            ;;
        *)
        echo "Unknown arg: $arg"
        exit 1
        ;;
    esac
done

run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] %q ' "$@"
        printf '\n'
    else
        "$@"
    fi
}

# Ask for admin once (some sections need sudo; risk section uses it more)
if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] sudo -v"
else
    sudo -v || true
fi

CURRENT_USER="$(/usr/bin/stat -f%Su /dev/console)"
CURRENT_UID="$(/usr/bin/id -u "$CURRENT_USER")"

as_user() {
    # Run as the logged-in user (important when script is run via sudo)
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] launchctl asuser %s sudo -u %q ' "$CURRENT_UID" "$CURRENT_USER"
        printf '%q ' "$@"
        printf '\n'
    else
       /bin/launchctl asuser "$CURRENT_UID" sudo -u "$CURRENT_USER" "$@"
    fi
}

###############################################################################
# Helpers
###############################################################################
set_default_browser_bundleid() {
  local bundle_id="$1"
  local ls_plist="${HOME}/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"

  run mkdir -p "$(dirname "$ls_plist")"
  # Create if missing (best-effort)
  if [[ ! -f "$ls_plist" ]]; then
    run /usr/bin/plutil -create binary1 "$ls_plist" || true
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] python3: set LSHandlers for http/https => $bundle_id"
    return 0
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

def upsert(handlers, scheme):
    new_handlers = []
    for h in handlers:
        if h.get("LSHandlerURLScheme") == scheme:
            continue
        new_handlers.append(h)
    new_handlers.append({"LSHandlerURLScheme": scheme, "LSHandlerRoleAll": bundle})
    return new_handlers

handlers = upsert(handlers, "http")
handlers = upsert(handlers, "https")
data["LSHandlers"] = handlers

with open(path, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)
PY
}

disable_symbolic_hotkey() {
    local id="$1"
    local plist="${HOME}/Library/Preferences/com.apple.symbolichotkeys.plist"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] python3: disable symbolic hotkey $id in $plist"
        return 0
    fi

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
entry["enabled"] = False
ashk[hotkey_id] = entry
data["AppleSymbolicHotKeys"] = ashk

with open(path, "wb") as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)
PY
}

###############################################################################
# CORE
###############################################################################
if [[ "$CORE" -eq 1 ]]; then
    echo "== CORE =="

    # General UI/UX
    as_user defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
    as_user defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    as_user defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    as_user defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    as_user defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    as_user defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    as_user defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    as_user defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Dark Mode (best-effort)
    as_user /usr/bin/osascript -e \
        'tell application "System Events" to tell appearance preferences to set dark mode to true' || true

    # Trackpad / keyboard / input (stable-ish)
    as_user defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    as_user defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    as_user defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    as_user defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    as_user defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    as_user defaults write NSGlobalDomain KeyRepeat -int 2
    as_user defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Screenshots
    run mkdir -p "${HOME}/Screenshots"
    as_user defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
    as_user defaults write com.apple.screencapture type -string "png"
    as_user defaults write com.apple.screencapture disable-shadow -bool true

    # Lock screen: require password immediately after sleep/screensaver
    as_user defaults write com.apple.screensaver askForPassword -int 1
    as_user defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Finder (safe toggles)
    as_user defaults write com.apple.finder QuitMenuItem -bool true
    as_user defaults write com.apple.finder AppleShowAllFiles -bool true
    as_user defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    as_user defaults write com.apple.finder ShowStatusBar -bool true
    as_user defaults write com.apple.finder ShowPathbar -bool true
    as_user defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    as_user defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    as_user defaults write com.apple.finder WarnOnEmptyTrash -bool false
    as_user defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    as_user defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    run chflags nohidden "${HOME}/Library" || true
    run sudo chflags nohidden /Volumes || true
    as_user defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

    # Dock / Mission Control (safe toggles)
    as_user defaults write com.apple.dock autohide -bool true
    as_user defaults write com.apple.dock mru-spaces -bool false
    # Your requested: Turn off "Show suggested and recent apps in Dock"
    as_user defaults write com.apple.dock show-recents -bool false || true

    # Control Center / Menu Bar (modern)
    # (Keep Bluetooth/Sound visible; adjust if you don’t want these.)
    as_user defaults -currentHost write com.apple.controlcenter Bluetooth -int 18 || true
    as_user defaults -currentHost write com.apple.controlcenter Sound -int 18 || true
    as_user defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true || true

    # Your requested: remove Wi-Fi + Spotlight from menu bar
    as_user defaults -currentHost write com.apple.controlcenter WiFi -int 24 || true
    as_user defaults -currentHost write com.apple.controlcenter Spotlight -int 24 || true

    # Your requested: “Click wallpaper to show desktop” -> “Only in Stage Manager”
    as_user defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0 || true

    # Your requested: Default web browser -> Arc
    if [[ -d "/Applications/Arc.app" ]]; then
        # Arc bundle id is typically: company.thebrowser.Browser
        set_default_browser_bundleid "company.thebrowser.Browser" || true
    else
        echo "Arc.app not found in /Applications; skipping default browser change."
    fi

    # Your requested: Display sleep timers (battery / power adapter)
    run sudo /usr/bin/pmset -b displaysleep 5
    run sudo /usr/bin/pmset -c displaysleep 30

    # Your requested: Turn off “Automatically adjust brightness”
    # (best-effort; ignored on Macs without ambient light sensor or if restricted)
    run sudo /usr/bin/defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false || true

    # Your requested: Disable Spotlight keyboard shortcuts
    # - Show Spotlight search (Cmd+Space): 64
    # - Show Finder search window (Opt+Cmd+Space): 65
    disable_symbolic_hotkey 64 || true
    disable_symbolic_hotkey 65 || true

    # Time Machine (safe)
    as_user defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Photos (safe)
    as_user defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true || true
fi

###############################################################################
# EXTENDED (nice-to-have; may drift across macOS versions)
###############################################################################
if [[ "$EXTENDED" -eq 1 ]]; then
    echo "== EXTENDED =="

    # Dock animation tweaks (can feel “off” after major updates; hence extended)
    as_user defaults write com.apple.dock autohide-delay -float 0 || true
    as_user defaults write com.apple.dock autohide-time-modifier -float 0 || true
    as_user defaults write com.apple.dock launchanim -bool false || true
    as_user defaults write com.apple.dock minimize-to-application -bool true || true
    as_user defaults write com.apple.dock showhidden -bool true || true
    as_user defaults write com.apple.dock tilesize -int 36 || true
    as_user defaults write com.apple.dock mineffect -string "scale" || true

    # Finder disk image + auto-open (often still works, sometimes ignored)
    as_user defaults write com.apple.frameworks.diskimages skip-verify -bool true || true
    as_user defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true || true
    as_user defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true || true
    as_user defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true || true
    as_user defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true || true
    as_user defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true || true

    # “Deep” Finder view tuning (brittle; Finder can overwrite these)
    # Uncomment if you really want them:
    # as_user /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" "${HOME}/Library/Preferences/com.apple.finder.plist" || true

    # Activity Monitor (purely cosmetic)
    as_user defaults write com.apple.ActivityMonitor OpenMainWindow -bool true || true
    as_user defaults write com.apple.ActivityMonitor IconType -int 5 || true
    as_user defaults write com.apple.ActivityMonitor ShowCategory -int 0 || true
    as_user defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage" || true
    as_user defaults write com.apple.ActivityMonitor SortDirection -int 0 || true

    # App Store / Software Update (often overridden by MDM; best-effort)
    as_user defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true || true
    as_user defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1 || true
    as_user defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1 || true
    as_user defaults write com.apple.commerce AutoUpdate -bool true || true

    # Safari small quality-of-life (optional)
    as_user defaults write com.apple.Safari IncludeDevelopMenu -bool true || true
    as_user defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true || true
    as_user defaults write com.apple.Safari AutoOpenSafeDownloads -bool false || true
fi

###############################################################################
# RISKY / SYSTEM-WIDE (OFF by default)
###############################################################################
if [[ "$RISK" -eq 1 ]]; then
    echo "== RISKY/SYSTEM =="

    # These can break captive/public Wi-Fi flows, local discovery (AirPrint/AirPlay),
    # or be undesirable on laptops. Only enable if you understand the tradeoffs.

    # Disable Captive Portal probing (may affect hotel/airport login detection)
    run sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false || true

    # Enable firewall stealth mode
    run sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true || true

    # Disable wake on network access
    run sudo /usr/sbin/systemsetup -setwakeonnetworkaccess off || true

    # Reduce Bonjour multicast advertisements (can break discovery features)
    run sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES || true

    # NVRAM boot sound disable (may be ignored / restricted on some Macs)
    run sudo /usr/sbin/nvram SystemAudioVolume=" " || true
fi

###############################################################################
# Apply changes
###############################################################################
echo "== RESTARTING UI SERVICES =="
run killall Finder >/dev/null 2>&1 || true
run killall Dock >/dev/null 2>&1 || true
run killall SystemUIServer >/dev/null 2>&1 || true
run killall cfprefsd >/dev/null 2>&1 || true

echo "Done. Some changes may require logout/restart to fully apply."
