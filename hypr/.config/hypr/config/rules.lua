--- Window Rules ---
hl.window_rule({
  name = "firefox-opacity",
  match = {
    class = "^(firefox)$",
  },
  opacity = "1.0 1.0 override",
})

--- Layer Rules ---
hl.layer_rule({
  name = "waybar",
  blur = true,
  match = {
    class = "waybar",
  },
})

hl.layer_rule({
  name = "rain-dock",
  match = {
    class = "^(Rain-Dock)$",
  },
  blur = false,
})
