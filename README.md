# dotfiles

## Installation

Interactive setup (prompts for each step):

```
./install/install.sh
```

Non-interactive (installs everything, no prompts):

```
./install/install.sh --non-interactive
```

## Adding an either/or cask group

To add a mutually exclusive set of casks (e.g. Docker Desktop vs OrbStack), edit `install/packages.sh`:

1. Add the group name to `CASK_GROUP_NAMES`
2. Define `CASK_GROUP_<NAME>_LABEL` (display header)
3. Define `CASK_GROUP_<NAME>_OPTIONS` as `"brew-name:Display Name"` entries

```bash
CASK_GROUP_NAMES=(CONTAINER EDITOR)

CASK_GROUP_EDITOR_LABEL="Code Editor"
CASK_GROUP_EDITOR_OPTIONS=(
    "visual-studio-code:Visual Studio Code"
    "cursor:Cursor"
)
```

# License

What license!? [WTFPL](http://www.wtfpl.net).
