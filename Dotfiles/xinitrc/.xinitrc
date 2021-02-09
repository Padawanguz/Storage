# Fix Display and make it 1080p
# xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP1 --mode 1920x1080

#Mount utility controlled with udiskie-dmenu
udiskie -ANT &

# Status msgs on system tray
slstatus &

# Wallpaper
xwallpaper --maximize ~/Storage/Images/Wallpapers/25462.jpg &

# Transmission torrent daemon
# transmission-daemon &

# Clipmenu control with dmenu
clipmenud &

# Mouse unclutter
unclutter &

# Mullvad VPN at start
# mullvad connect && sleep 5 && mullvad reconnect &
mullvad connect

# Protonmail bridge daemon
sleep 10 && protonmail-bridge --noninteractive &

#Start dwm with startx
exec dwm
