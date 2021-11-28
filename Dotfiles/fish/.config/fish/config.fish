# Fisher installer
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Puts local/bin on $PATH
set fish_user_paths $HOME/.local/bin $fish_user_paths


# Puts snap on $PATH
set fish_user_paths /var/lib/snapd/snap/bin $fish_user_paths

# Puts rbenv on $PATH
set fish_user_paths $HOME/.rbenv/bin $fish_user_paths
set fish_user_paths $HOME/.rbenv/shims $fish_user_paths
rbenv rehash >/dev/null

# Set Enviroment Variables
set -Ux EDITOR nvim
set -Ux TERMINAL st
set -Ux BROWSER surf

# Removes unnecesary $HOME clutter
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CACHE_HOME $HOME/.cache
set -x WGETRC $HOME/.config/wget/wgetrc
# set -x GNUPGHOME $HOME/.config/gnupg
set -x GTK2_RC_FILES $HOME/.config/gtk-2.0/.gtkrc-2.0
set -x ELECTRUMDIR $HOME/.local/share/electrum
set -x HISTFILE $HOME/.local/share/history
set -x GOPATH $HOME/.local/share/go
# set -x GEM_HOME $HOME/.local/share/gem
# set -x GEM_PATH $HOME/.local/share/gem
set -x NPM_CONFIG_USERCONFIG $HOME/.config/npm
set -x MBSYNCRC $HOME/.config/mbsync/config
set -x CARGO_HOME $HOME/.local/share/cargo
# set -x PASSWORD_STORE_DIR $HOME/.local/share/password-store

# Open 'su' with fish shell
function su
   command su --shell=/usr/bin/fish $argv
end

# Start X at login
if status is-login
  sleep 1 &
  wait $last_pid
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx -- -keeptty
  end
end
