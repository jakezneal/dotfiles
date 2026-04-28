#!/usr/bin/env bash

###############################################################################
# App groups
###############################################################################
productivity=(
    "Canary Mail"
    "Notion Calendar"
    "Slack"
    "Microsoft Teams"
    "1Password"
    "ChatGPT"
)

misc=(
    "Arc"
    "Spotify"
)

design=(
    "Figma"
)

development=(
    "Visual Studio Code"
    "Warp"
    "GitHub Desktop"
    "TablePlus"
    "Postman"
    "Bruno"
)

DOCK_GROUPS=("productivity" "misc" "design" "development")

###############################################################################
# Build Dock
###############################################################################
dockutil --no-restart --remove all

group_count=${#DOCK_GROUPS[@]}
group_idx=0

for group_name in "${DOCK_GROUPS[@]}"; do
    group_idx=$(( group_idx + 1 ))
    group_added=0
    group_last=""
    eval 'apps=("${'"$group_name"'[@]}")'

    for app in "${apps[@]}"; do
        if [[ -d "/Applications/${app}.app" ]]; then
            dockutil --no-restart --add "/Applications/${app}.app"
            group_added=1
            group_last="$app"
        fi
    done

    # Add a spacer after this group (skip the last group)
    if [[ "$group_added" -eq 1 && "$group_idx" -lt "$group_count" ]]; then
        dockutil --no-restart --add '' --type spacer --section apps --after "$group_last"
    fi
done

killall Dock
