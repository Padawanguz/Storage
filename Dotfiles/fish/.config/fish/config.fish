
# Puts local/bin on $PATH
set PATH $HOME/.local/bin $PATH

# Puts rbenv on $PATH
set PATH $HOME/.rbenv/bin $PATH
set PATH $HOME/.rbenv/shims $PATH
# rbenv rehash >/dev/null ^&1

# Change GOPATH
set -x GOPATH $HOME/.go

# Set Enviroment Variables
set -Ux EDITOR nvim
set -Ux TERMINAL st


# Fisher installer
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Open 'su' with fish shell
function su
   command su --shell=/usr/bin/fish $argv
end

function ranger-cd
    set tmpfile "/tmp/pwd-from-ranger"
    ranger --choosedir=$tmpfile $argv
    set rangerpwd (cat $tmpfile)
    if test "$PWD" != $rangerpwd
        cd $rangerpwd
    end
end

# Start X at login
if status is-login
  sleep 1 &
  wait $last_pid
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx -- -keeptty
  end
end
