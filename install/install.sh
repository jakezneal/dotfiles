#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR=~/dotfiles

###############################################################################
# Flags
###############################################################################
NON_INTERACTIVE=0
DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --non-interactive) NON_INTERACTIVE=1 ;;
        --dry-run) DRY_RUN=1 ;;
    esac
done

export DRY_RUN

run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

###############################################################################
# 1. Homebrew
###############################################################################
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew…"
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo '[dry-run] /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

###############################################################################
# 2. Bootstrap required tools (gum for prompts, dockutil for dock)
###############################################################################
source "$DOTFILES_DIR/install/packages.sh"

for pkg in gum "${REQUIRED_FORMULAE[@]}"; do
    brew list "$pkg" &>/dev/null || brew install "$pkg"
done

###############################################################################
# Helper: prompt for a list of items with All / None / Pick
###############################################################################
pick_packages() {
    local header="$1"
    local arr_name="$2"
    PICKED=""

    eval 'local items=("${'"$arr_name"'[@]}")'

    if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
        PICKED="$(printf '%s\n' "${items[@]}")"
        return
    fi

    local choice
    choice="$(printf '%s\n' "All" "None" "${items[@]}" \
        | gum choose --no-limit --header "$header" --height $(( ${#items[@]} + 4 )))"

    # Parse selection
    if echo "$choice" | grep -qx "All"; then
        PICKED="$(printf '%s\n' "${items[@]}")"
    elif echo "$choice" | grep -qx "None"; then
        PICKED=""
    else
        PICKED="$choice"
    fi
}

###############################################################################
# Helper: prompt for an either/or group (single-select)
###############################################################################
pick_group() {
    local group="$1"
    local label_var="CASK_GROUP_${group}_LABEL"
    local opts_var="CASK_GROUP_${group}_OPTIONS"
    local label="${!label_var}"
    GROUP_PICK=""

    eval 'local opts=("${'"$opts_var"'[@]}")'

    # Build display list
    local display_names=()
    local brew_names=()
    for entry in "${opts[@]}"; do
        brew_names+=("${entry%%:*}")
        display_names+=("${entry#*:}")
    done

    if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
        # Default to the first option in non-interactive mode
        GROUP_PICK="${brew_names[0]}"
        return
    fi

    local choice
    choice="$(printf '%s\n' "${display_names[@]}" "None" \
        | gum choose --header "$label" --height $(( ${#display_names[@]} + 3 )))"

    if [[ "$choice" == "None" ]]; then
        GROUP_PICK=""
        return
    fi

    # Map display name back to brew name
    for i in "${!display_names[@]}"; do
        if [[ "${display_names[$i]}" == "$choice" ]]; then
            GROUP_PICK="${brew_names[$i]}"
            return
        fi
    done
}

###############################################################################
# 3. Select formulae
###############################################################################
pick_packages "Select formulae to install" FORMULAE
SELECTED_FORMULAE="$PICKED"

# Always include required formulae
for pkg in "${REQUIRED_FORMULAE[@]}"; do
    SELECTED_FORMULAE="$(printf '%s\n%s' "$pkg" "$SELECTED_FORMULAE")"
done

###############################################################################
# 4. Select casks
###############################################################################
pick_packages "Select casks to install" CASKS
SELECTED_CASKS="$PICKED"

# Either/or groups
for group in "${CASK_GROUP_NAMES[@]}"; do
    pick_group "$group"
    if [[ -n "$GROUP_PICK" ]]; then
        SELECTED_CASKS="$(printf '%s\n%s' "$GROUP_PICK" "$SELECTED_CASKS")"
    fi
done

###############################################################################
# 5. Select macOS defaults tier
###############################################################################
if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    DEFAULTS_CHOICE="Core + Extended"
else
    DEFAULTS_CHOICE="$(printf '%s\n' \
        "Core only" \
        "Core + Extended" \
        "Core + Extended + Risky" \
        "Skip" \
        | gum choose --header "macOS defaults tier")"
fi

###############################################################################
# 6. Summary & confirm
###############################################################################
show_summary() {
    local formulae_list cask_list
    formulae_list="${SELECTED_FORMULAE:-None}"
    cask_list="${SELECTED_CASKS:-None}"

    gum style \
        --border rounded --padding "1 2" --border-foreground 212 \
        "$(gum style --bold '📦 Formulae')" \
        "$formulae_list" \
        "" \
        "$(gum style --bold '🖥  Casks')" \
        "$cask_list" \
        "" \
        "$(gum style --bold '⚙️  macOS Defaults')" \
        "$DEFAULTS_CHOICE"
}

if [[ "$NON_INTERACTIVE" -eq 0 ]]; then
    show_summary
    gum confirm "Proceed with installation?" || exit 0
fi

###############################################################################
# 7. Install packages
###############################################################################
export SELECTED_FORMULAE SELECTED_CASKS
. "$DOTFILES_DIR/install/brew.sh"

###############################################################################
# 8. Symlinks (always all)
###############################################################################
if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] source symlinks.sh"
else
    . "$DOTFILES_DIR/install/symlinks.sh"
fi

###############################################################################
# 9. macOS defaults
###############################################################################
defaults_args=()
case "$DEFAULTS_CHOICE" in
    "Core only")      defaults_args=(--core-only) ;;
    "Core + Extended") ;;
    "Core + Extended + Risky") defaults_args=(--risk) ;;
    "Skip")
        echo "Skipping macOS defaults."
        ;;
esac

if [[ "$DEFAULTS_CHOICE" != "Skip" ]]; then
    [[ "$DRY_RUN" -eq 1 ]] && defaults_args+=(--dry-run)
    . "$DOTFILES_DIR/macos/defaults.sh" "${defaults_args[@]}"
fi

###############################################################################
# 10. Dock
###############################################################################
if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] source dock.sh"
else
    . "$DOTFILES_DIR/macos/dock.sh"
fi

echo "✅ All done!"
