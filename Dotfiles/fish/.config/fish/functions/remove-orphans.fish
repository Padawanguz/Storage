# Defined in - @ line 1
function remove-orphans --description 'alias remove-orphans=sudo pacman -Rns (pacman -Qtdq)'
	sudo pacman -Rns (pacman -Qtdq) $argv;
end
