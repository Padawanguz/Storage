# Defined in - @ line 1
function wifi-connect --description 'alias wifi-connect=nmcli device wifi connect'
	nmcli device wifi connect $argv;
end
