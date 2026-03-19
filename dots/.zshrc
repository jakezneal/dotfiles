# Cache starship init output — only regenerates when the binary changes
_starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship-init.zsh"
if [[ ! -f "$_starship_cache" || "$(command -v starship)" -nt "$_starship_cache" ]]; then
	mkdir -p "${_starship_cache%/*}"
	starship init zsh > "$_starship_cache"
fi
source "$_starship_cache"
unset _starship_cache

. $HOME/z.sh

for file in ~/.{exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
