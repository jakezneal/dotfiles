#!/bin/sh

apps=(
    "Astro"
    "Slack"
    "Spotify"

    "Google Chrome"
    "Google Chrome Canary"
    "Firefox"
    "Safari"

    "Visual Studio Code"
    "iTerm"
    "Tower"
    "TablePlus"
    "Cyberduck"

    "MacDown"
)

dockutil --no-restart --remove all

for app in "${apps[@]}"; do
    dockutil --no-restart --add "/Applications/${app}.app"
done;

dockutil --add '' --type spacer --section apps --after "Finder"
dockutil --add '' --type spacer --section apps --after "Spotify"
dockutil --add '' --type spacer --section apps --after "Safari"
dockutil --add '' --type spacer --section apps --after "Cyberduck"

killall Dock
