# Defined in - @ line 1
function batstatus --wraps='upower -i /org/freedesktop/UPower/devices/battery_BAT0' --description 'alias batstatus=upower -i /org/freedesktop/UPower/devices/battery_BAT0'
  upower -i /org/freedesktop/UPower/devices/battery_BAT0 $argv;
end
