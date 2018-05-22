# List VS Code plugins
code=(
    Alan.stylus
    HvyIndustries.crane
    agauniyal.vscode-caniuse
    christian-kohler.npm-intellisense
    christian-kohler.path-intellisense
    formulahendry.auto-rename-tag
    mrmlnc.vscode-scss
    pflannery.vscode-versionlens
    wayou.vscode-todo-highlight
    whatwedo.twig
)

# Install plugins
for plugin in "${code[@]}"; do
    code --install-extension $plugin
done;
