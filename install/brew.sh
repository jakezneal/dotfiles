#!/usr/bin/env bash
# Install selected packages via Homebrew

set -euo pipefail

run() {
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

run brew update
run brew upgrade

# --- Formulae ---
if [[ -n "${SELECTED_FORMULAE:-}" ]]; then
    while IFS= read -r formula; do
        [[ -z "$formula" ]] && continue
        run brew install "$formula"
    done <<< "$SELECTED_FORMULAE"
fi

# --- Casks ---
if [[ -n "${SELECTED_CASKS:-}" ]]; then
    while IFS= read -r cask; do
        [[ -z "$cask" ]] && continue
        run brew install --cask --appdir="/Applications" "$cask"
    done <<< "$SELECTED_CASKS"
fi
