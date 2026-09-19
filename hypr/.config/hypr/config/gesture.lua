--- Change Workspace ---
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

--- Close Window ---
hl.gesture({
  fingers = 3,
  direction = "down",
  scale = 2,
  action = "close",
})

--- Fullscreen ---
hl.gesture({
  fingers = 3,
  direction = "up",
  action = "fullscreen",
})

--- Floating Window ---
hl.gesture({
  fingers = 3,
  direction = "pinchout",
  scale = 1.5,
  action = "float",
})

--- Zoom ---
hl.gesture({
  fingers = 2,
  direction = "pinch",
  mods = "SUPER",
  action = "cursorZoom",
  zoom_level = 1,
  mode = "live",
})

--- Move Window ---
-- drag window
hl.gesture({
  fingers = 3,
  direction = "swipe",
  mods = "SUPER",
  action = "move",
})

-- move window to next workspace
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  mods = "SUPER SHIFT",
  ---@diagnostic disable-next-line
  action = {
    start = function(e)
      if e.delta.x < 0 then
        hl.dispatch(hl.dsp.window.move({ workspace = "e-1" }))
      elseif e.delta.x > 0 then
        hl.dispatch(hl.dsp.window.move({ workspace = "e+1" }))
      end
    end,

    finish = function() end,
  },
})

--- Scroll Windows ---
-- only works in scrolling layout
hl.gesture({
  fingers = 4,
  direction = "horizontal",
  mods = "SUPER",
  action = "scroll_move",
})

--- Resize ---
hl.gesture({
  fingers = 3,
  direction = "swipe",
  mods = "ALT",
  scale = 1.5,
  action = "resize",
})

--- Special ---
hl.gesture({
  fingers = 3,
  direction = "pinchin",
  scale = 2,
  action = "special",
  workspace_name = "magic",
})

--- Volume ---
local volume_gesture = function(change)
  hl.exec_cmd(
    "wpctl set-volume @DEFAULT_AUDIO_SINK@ "
      .. math.abs(change)
      .. "%"
      .. (change < 0 and "-" or "+")
  )
end
hl.gesture({
  fingers = 4,
  direction = "vertical",
  ---@diagnostic disable-next-line
  action = {
    start = function(e)
      volume_gesture(-0.25 * e.delta.y)
    end,
    update = function(e)
      volume_gesture(-0.25 * e.delta.y)
    end,
  },
})

--- Brightness ---
local brightness_gesture = function(change)
  hl.exec_cmd(
    "brightnessctl s "
      .. math.min(math.abs(change), 100)
      .. "%"
      .. (change > 0 and "-" or "+")
  )
end
hl.gesture({
  fingers = 4,
  direction = "horizontal",
  ---@diagnostic disable-next-line
  action = {
    start = function(e)
      brightness_gesture(-0.25 * e.delta.x)
    end,
    update = function(e)
      brightness_gesture(-0.25 * e.delta.x)
    end,
  },
})

--- Rotate Layout ---
-- only works in dwindle
hl.gesture({
  fingers = 3,
  direction = "pinch",
  mods = "SUPER",
  ---@diagnostic disable-next-line
  action = {
    start = function(e)
      ---@type number
      local angle = e.rotation
      if angle > 0 then
        hl.dispatch(hl.dsp.layout("rotatesplit +90"))
      elseif angle < 0 then
        hl.dispatch(hl.dsp.layout("rotatesplit -90"))
      end
    end,
  },
})
