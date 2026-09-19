hl.on("hyprland.start", function()
  -- status bar
  hl.exec_cmd("waybar")

  -- idle daemon
  hl.exec_cmd("hypridle")

  -- wallpaper
  hl.exec_cmd("hyprpaper")

  -- set the dark theme in gtk
  hl.exec_cmd(
    'gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"'
  )
  hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"')

  -- clipboard
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
