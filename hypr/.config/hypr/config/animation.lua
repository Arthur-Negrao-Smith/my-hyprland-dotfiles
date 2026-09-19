local state = require("config.state")

--- CURVES ---
hl.curve(
  "easeOutQuint",
  { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } }
)
hl.curve(
  "easeInOutCubic",
  { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } }
)
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve(
  "almostLinear",
  { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } }
)
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

--- Springs ---

-- Windows
hl.curve("window_open_spring", {
  type = "spring",
  mass = 1,
  stiffness = 100,
  dampening = 13,
})

hl.curve("window_move_spring", {
  type = "spring",
  mass = 1,
  stiffness = 70,
  dampening = 12,
})

-- Workspaces
hl.curve("workspace_spring", {
  type = "spring",
  mass = 1,
  stiffness = 70,
  dampening = 14,
})

hl.curve("workspace_special_spring", {
  type = "spring",
  mass = 1,
  stiffness = 75,
  dampening = 13,
})

--- ANIMATIONS ---

--- Global---
hl.animation({
  leaf = "global",
  enabled = true,
  speed = 10,
  bezier = "easeOutQuint",
})

--- Windows Open/Close ---
hl.animation({
  leaf = "windows",
  enabled = true,
  speed = 4.5,
  bezier = "easeOutQuint",
})
hl.animation({
  leaf = "windowsIn",
  enabled = true,
  speed = 1.3,
  -- bezier = "easeInOutCubic",
  spring = "window_open_spring",
  style = "popin 87%",
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 1.5,
  bezier = "linear",
  style = "popin 87%",
})
hl.animation({
  leaf = "windowsMove",
  enabled = true,
  speed = 1.1,
  spring = "window_move_spring",
  style = "slide",
})

--- Window Open/Close (Fade) ---
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({
  leaf = "fadeIn",
  enabled = true,
  speed = 1.7,
  bezier = "almostLinear",
})
hl.animation({
  leaf = "fadeOut",
  enabled = true,
  speed = 1.5,
  bezier = "almostLinear",
})
hl.animation({
  leaf = "fadeSwitch",
  enabled = true,
  speed = 1.5,
  bezier = "easeInOutCubic",
})

--- Workspaces ---

---@param orientation WorkspaceOrientation
local update_workspace_orientation = function(orientation)
  -- Normal Workspace
  hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 2.2,
    spring = "workspace_spring",
    style = (orientation == "horizontal") and "slidefade" or "slidefadevert",
  })
  hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 3,
    spring = "workspace_spring",
    style = (orientation == "horizontal") and "slidefade" or "slidefadevert",
  })

  -- Special Workspace
  hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 0.5,
    spring = "workspace_special_spring",
    style = (orientation == "vertical") and "slidefade" or "slidefadevert",
  })

  hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 1.5,
    spring = "workspace_special_spring",
    style = (orientation == "vertical") and "slidefade" or "slidefadevert",
  })
end

-- apply animation
update_workspace_orientation(state.workspace.orientation)

-- subscribe callback
state.workspace:on_orientation_changed(update_workspace_orientation)

--- Layers ---
hl.animation({
  leaf = "layers",
  enabled = true,
  speed = 3.8,
  bezier = "easeOutQuint",
})
hl.animation({
  leaf = "layersIn",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "fade",
})
hl.animation({
  leaf = "layersOut",
  enabled = true,
  speed = 1.5,
  bezier = "linear",
  style = "fade",
})

--- Focus (Borders) ---
hl.animation({
  leaf = "border",
  enabled = true,
  speed = 2.5,
  bezier = "quick",
})

hl.animation({
  leaf = "fadeSwitch",
  enabled = true,
  speed = 2.5,
  bezier = "easeOutQuint",
})
