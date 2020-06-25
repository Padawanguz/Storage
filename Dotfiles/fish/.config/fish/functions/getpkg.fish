# Defined in /home/guz/.config/fish/functions/getpkg.fish @ line 1
function getpkg
  yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S
end
