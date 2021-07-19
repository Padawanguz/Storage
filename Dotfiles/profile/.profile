
# Adds `~/.local/bin` to $PATH
export PATH="$HOME/.local/bin:$PATH"

# Adds rbenv to $PATH
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"

# Default programs:
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="surf"

# Removes unnecesary $HOME clutter
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/.gtkrc-2.0"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export ELECTRUMDIR="${XDG_DATA_HOME:-$HOME/.local/share}/electrum"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
