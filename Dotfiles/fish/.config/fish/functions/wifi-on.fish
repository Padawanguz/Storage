# Defined in - @ line 1
function wifi-on --description 'alias wifi-on=nmcli radio wifi on'
	nmcli radio wifi on $argv;
end
