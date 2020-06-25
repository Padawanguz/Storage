# Defined in - @ line 1
function wifi-scan --description 'alias wifi-scan=nmcli device wifi rescan'
	nmcli device wifi rescan $argv;
end
