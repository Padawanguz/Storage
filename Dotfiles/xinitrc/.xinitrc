# Fix Display and make it 1080p
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP1 --mode 1920x1080

#Mount utility controlled with udiskie-dmenu
udiskie -ANT &

# Status msgs on system tray
slstatus &

# Wallpaper
setbg &

# Disable trackpad on boot - good habits!
xinput disable 'DLL07BE:01 06CB:7A13 Touchpad'

# Transmission torrent daemon
# transmission-daemon &

# Clipmenu control with dmenu
clipmenud &

# Mouse unclutter
unclutter &

# Protonmail bridge daemon
sleep 0 && protonmail-bridge --noninteractive &

#Start dwm with startx
exec dwm
