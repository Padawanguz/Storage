# Enable colors and change prompt:
autoload -U colors && colors
PS1="%B%{$fg[white]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[white]%}]%{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Some useful aliases
alias getpkg="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"   # Uses yay and fzf to find Arch packages
alias remove-orphans="sudo pacman -Rns $(pacman -Qtdq)"
alias wifi-list="nmcli device wifi list"
alias wifi-on="nmcli radio wifi on"
alias wifi-connect="nmcli device wifi connect"
alias wifi-off="nmcli radio wifi off"
alias wifi-scan="nmcli device wifi rescan"
alias batstatus="upower -i /org/freedesktop/UPower/devices/battery_BAT0"
alias allpkgs="pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
alias ls="ls --color=auto"
alias rm="echo 'This is not the command you are looking for.'; false"


# Load zsh-syntax-highlighting and zsh-autosuggestions
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/doc/pkgfile/command-not-found.zsh
