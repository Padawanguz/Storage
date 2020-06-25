# Defined in - @ line 1
function wifi-list --description 'alias wifi-list=nmcli device wifi list'
	nmcli device wifi list $argv;
end
