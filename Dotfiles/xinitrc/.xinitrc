# Fix Display and make it 1080p
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP1 --mode 1920x1080

# Status msgs on system tray
slstatus &

# Wallpaper
setbg &

# Disable trackpad on boot - good habits!
# xinput disable 'DLL07BE:01 06CB:7A13 Touchpad'

# Transmission torrent daemon
# transmission-daemon &

# Clipmenu control with dmenu
clipmenud &

# Climenu synchronization
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

# Mouse unclutter
unclutter &

# Protonmail bridge daemon
# protonmail-bridge --noninteractive &

#Start dwm with startx
exec dwm
