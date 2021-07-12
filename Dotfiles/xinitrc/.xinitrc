# Fix Display and make it 1080p
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP1 --mode 1920x1080

#Mount utility controlled with udiskie-dmenu
udiskie -ANT &

# Status msgs on system tray
slstatus &

# Wallpaper
xwallpaper --maximize ~/Storage/Images/Wallpapers/AJLTxv3ua0eivZS9R9IaBNnfbkE2QX4BBVagazZPyV8.jpg &

# Transmission torrent daemon
# transmission-daemon &

# Clipmenu control with dmenu
clipmenud &

# Mouse unclutter
unclutter &

# Protonmail bridge daemon
sleep 10 && protonmail-bridge --noninteractive &

#Start dwm with startx
exec dwm
