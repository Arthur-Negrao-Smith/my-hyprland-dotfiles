local MAIN_MOD = "SUPER"
local SHIFT = "SHIFT"

local MOUSE_LEFT = "mouse:272"
local MOUSE_RIGHT = "mouse:273"

local TERMINAL = "kitty"
local BROWSER = "firefox"
local FILE_MANAGER = "nautilus"
local LAUNCHER = "rofi"
local LAUNCHER_FLAGS = "-show drun -show-icons"
local LOGOUT_MENU = "wlogout"
local LOGOUT_MENU_FLAGS = "-c 5 -r 5"

local state = require("config.state")

--- a function to join keys and avoid boilerplate
---@param keys string[]
---@return string
local function join_keys(keys)
  ---@type string
  local buffer = ""

  ---@type number
  local keys_len = #keys

  for i, key in ipairs(keys) do
    buffer = buffer .. key

    if i ~= keys_len then
      buffer = buffer .. " + "
    end
  end

  return buffer
end

---@param keys string[]
---@return string
local function join_with_main(keys)
  table.insert(keys, 1, MAIN_MOD)

  local buffer = join_keys(keys)
  return buffer
end

---@param keys string[]
---@param dispatch function | HL.Dispatcher
---@param flags HL.BindOptions?
local function bind_main(keys, dispatch, flags)
  hl.bind(join_with_main(keys), dispatch, flags)
end

---@param keys string[]
---@param dispatch function | HL.Dispatcher
---@param flags HL.BindOptions?
local function bind(keys, dispatch, flags)
  hl.bind(join_keys(keys), dispatch, flags)
end

--- Basic Binds ---
bind_main({ "Q" }, hl.dsp.window.close(), { description = "Close window" })
bind_main({ "escape" }, hl.dsp.exit(), { description = "Exit Hyprland" })
bind_main(
  { "V" },
  hl.dsp.window.float(),
  { description = "Toggle floating window" }
)
bind_main({ "O" }, function()
  state.layout:toggle_split()
end, { description = "Toggle split layout (only in dwindle)" })

--- Basic App Binds ---
bind_main(
  { "X" },
  hl.dsp.exec_cmd(
    "pkill " .. LAUNCHER .. " || " .. LAUNCHER .. " " .. LAUNCHER_FLAGS
  ),
  { description = "Open Launcher" }
)
bind_main({ "T" }, hl.dsp.exec_cmd(TERMINAL), { description = "Open Terminal" })
bind_main({ "F" }, hl.dsp.exec_cmd(BROWSER), { description = "Open Browser" })
bind_main(
  { "E" },
  hl.dsp.exec_cmd(FILE_MANAGER),
  { description = "Open File Manager" }
)

--- Navigation Binds ---
local directions = {
  left = "left",
  right = "right",
  up = "up",
  down = "down",
  H = "left",
  L = "right",
  K = "up",
  J = "down",
}

for key, dir in pairs(directions) do
  -- move focus
  bind_main(
    { key },
    hl.dsp.focus({ direction = dir }),
    { description = "Change window focus to " .. dir }
  )

  -- move window
  bind_main({ SHIFT, key }, hl.dsp.window.move({ direction = dir }), {
    description = "Move window to " .. dir,
  })
end

--- Resize Window ---
for key, dir in pairs(directions) do
  ---@type number, number
  local x, y = 0, 0

  ---@type number
  local default_pass = 10

  if dir == "up" then
    y = -default_pass
  elseif dir == "down" then
    y = default_pass
  elseif dir == "right" then
    x = default_pass
  elseif dir == "left" then
    x = -default_pass
  end

  bind_main(
    { "ALT", key },
    hl.dsp.window.resize({
      x = x,
      y = y,
      relative = true,
    }),
    { repeating = true, { description = "Resize window" } }
  )
end

--- Change Workspace ---
for key = 0, 9 do
  bind_main(
    { "" .. key },
    hl.dsp.focus({ workspace = "" .. key }),
    { description = "Change to workspace " .. key }
  )
  bind_main(
    { SHIFT, "" .. key },
    hl.dsp.window.move({ workspace = "" .. key }),
    { description = "Move window to workspace " .. key }
  )
end

--- Window Status ---
bind_main(
  { "M" },
  hl.dsp.window.fullscreen({ action = "toggle" }),
  { description = "Toggle window fullscreen" }
)
bind(
  { "F11" },
  hl.dsp.window.fullscreen({ action = "toggle" }),
  { description = "Toggle window fullscreen" }
)

--- Special Workspace ---
bind_main(
  { "S" },
  hl.dsp.workspace.toggle_special("magic"),
  { description = "Toggle special workspace" }
)
bind_main(
  { SHIFT, "S" },
  hl.dsp.window.move({ workspace = "special:magic" }),
  { description = "Move windo to special workspace" }
)

--- Mouse Window ---
bind_main(
  { MOUSE_LEFT },
  hl.dsp.window.drag(),
  { mouse = true, description = "Drag window" }
)
bind_main(
  { MOUSE_RIGHT },
  hl.dsp.window.resize(),
  { mouse = true, description = "Resize window" }
)

--- Mouse Workspace ---
bind_main({ "mouse_down" }, function()
  if state.layout ~= "scrolling" then
    hl.dsp.focus({ workspace = "e-1" })
  else
    hl.dsp.focus({ window = "left" })
  end
end, { description = "Move window to previous workspace" })
bind_main({ "mouse_up" }, function()
  if state.layout ~= "scrolling" then
    hl.dsp.focus({ workspace = "e+1" })
  else
    hl.dsp.focus({ window = "right" })
  end
end, { description = "Move window to next workspace" })

--- System Lock ---
bind_main({ "C" }, hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })

--- Print/ ScreenShot ---
bind(
  { "Print" },
  hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"),
  { description = "Print a screen" }
)
bind_main(
  { "Print" },
  hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"),
  { description = "Print a region" }
)
bind(
  { SHIFT, "Print" },
  hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots"),
  { description = "Print a window" }
)

--- Logout Menu ---
bind_main(
  { "A" },
  hl.dsp.exec_cmd(
    "pkill " .. LOGOUT_MENU .. " || " .. LOGOUT_MENU .. " " .. LOGOUT_MENU_FLAGS
  ),
  { description = "Toggle Logout Menu" }
)

--- Volume and Brightness ---
bind(
  { "XF86AudioRaiseVolume" },
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { repeating = true, locked = true, description = "Increase volume" }
)
bind(
  { "XF86AudioLowerVolume" },
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"),
  { repeating = true, locked = true, description = "Decrease volume" }
)
bind(
  { "XF86AudioMute" },
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { repeating = false, locked = true, description = "Toggle audio" }
)
bind(
  { "XF86AudioMicMute" },
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { repeating = false, locked = true, description = "Toggle mic" }
)
bind(
  { "XF86MonBrightnessUp" },
  hl.dsp.exec_cmd("brightnessctl s 10%+"),
  { repeating = true, description = "Increase brightness" }
)
bind(
  { "XF86MonBrightnessDown" },
  hl.dsp.exec_cmd("brightnessctl s 10%-"),
  { repeating = true, description = "Decrease brightness" }
)

bind_main(
  { "bracketright" },
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { repeating = true, locked = true, description = "Increase volume" }
)
bind_main(
  { "bracketleft" },
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"),
  { repeating = true, locked = true, description = "Decrease volume" }
)
bind_main(
  { "Backspace" },
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { repeating = false, locked = true, description = "Toggle audio" }
)
bind_main(
  { SHIFT, "Backspace" },
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { repeating = false, locked = true, description = "Toggle mic" }
)
bind_main(
  { SHIFT, "bracketright" },
  hl.dsp.exec_cmd("brightnessctl s 10%+"),
  { repeating = true, description = "Increase brightness" }
)
bind_main(
  { SHIFT, "bracketleft" },
  hl.dsp.exec_cmd("brightnessctl s 10%-"),
  { repeating = true, description = "Decrease brightness" }
)

--- Media Control ---
bind(
  { "XF86AudioPrev" },
  hl.dsp.exec_cmd("playerctl previous"),
  { repeating = false, locked = true, description = "Play next track" }
)
bind(
  { "XF86AudioNext" },
  hl.dsp.exec_cmd("playerctl next"),
  { repeating = false, locked = true, description = "Play next track" }
)
bind(
  { "XF86AudioPause" },
  hl.dsp.exec_cmd("playerctl play-pause"),
  { repeating = false, locked = true, description = "Play/Pause media" }
)
bind(
  { "XF86AudioPlay" },
  hl.dsp.exec_cmd("playerctl play-pause"),
  { repeating = false, locked = true, description = "Play/Pause media" }
)

bind_main(
  { "comma" },
  hl.dsp.exec_cmd("playerctl previous"),
  { repeating = false, locked = true, description = "Play previous track" }
)
bind_main(
  { "period" },
  hl.dsp.exec_cmd("playerctl next"),
  { repeating = false, locked = true, description = "Play next track" }
)
bind_main(
  { "semicolon" },
  hl.dsp.exec_cmd("playerctl play-pause"),
  { repeating = false, locked = true, description = "Play/Pause media" }
)

--- Layout ---
bind_main({ "D" }, function()
  state.layout:toggle_layout()
end, { description = "Toggle window manager layout" })

--- Zoom ---
local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
  local current = hl.get_config("cursor.zoom_factor")
  if offset ~= nil then
    current = current + offset
  elseif current ~= MIN_ZOOM then
    current = MIN_ZOOM
  else
    current = ZOOM_TOGGLE_FACTOR
  end
  current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
  hl.config({ cursor = { zoom_factor = current } })
end

bind_main({ "Z" }, zoom, { description = "Toggle zoom" })
bind_main({ "equal" }, function()
  zoom(0.5)
end, { description = "Decrease zoom" })
bind_main({ "minus" }, function()
  zoom(-0.5)
end, { description = "Increase zoom" })

--- Keyboard Layout ---
bind_main({ "Space" }, function()
  hl.exec_cmd("hyprctl switchxkblayout current next")
  state.hypr_notify("Keyboard layout changed")
end, { description = "Switch keyboard layout" })

--- Toggle Workspaces Orientation ---
bind_main({ "ALT", "W" }, function()
  state.workspace:toggle_orientation()
end, { description = "Toggle workspace orientation" })

--- Restart Hyprland ---
bind_main({ SHIFT, "R" }, function()
  state.restart()
end, { description = "Restart all Hyprland configs and daemons" })
