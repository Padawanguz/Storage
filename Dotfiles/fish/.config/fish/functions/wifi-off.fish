# Defined in - @ line 1
function wifi-off --description 'alias wifi-off=nmcli radio wifi off'
	nmcli radio wifi off $argv;
end
