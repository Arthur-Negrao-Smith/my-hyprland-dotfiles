local M = {}

--- General ---

---@enum NotifyType
local NotifyType = {
  Default = 0,
  Alert = 1,
  Success = 2,
  Warn = 3,
  Error = 4,
}

--- Get a custom color by a `NotifyType`
---@param type NotifyType?
---@return string?
local function get_notify_color(type)
  local type_local = type or NotifyType.Default

  local color = nil
  if type_local == NotifyType.Default then
    color = "#4c0ccc"
  elseif type_local == NotifyType.Alert then
    color = "#a07aeb" -- "#1ecfeb"
  elseif type_local == NotifyType.Success then
    color = "#15ab24"
  elseif type_local == NotifyType.Warn then
    color = "#c7b924"
  elseif type_local == NotifyType.Error then
    color = "#bf0f02"
  end

  return color
end

---@class NotifyOpts
---@field timeout number? Timeout in ms (default: 5000)
---@field type NotifyType? Message type (default: Default)
local NotifyOpts = {}
NotifyOpts.__index = NotifyOpts

function NotifyOpts:new(opts)
  local instance = {}

  setmetatable(instance, self)

  if opts ~= nil then
    instance.timeout = opts.timeout
    instance.type = opts.type
  end

  return instance
end

---@param msg string
---@param opts NotifyOpts?
M.hypr_notify = function(msg, opts)
  local opts_local = NotifyOpts:new(opts)

  hl.notification.create({
    text = msg,
    timeout = opts_local.timeout or 5000,
    color = get_notify_color(opts_local.type),
  })
end

-- Restart
--- Restart all Hyprland state and daemons (Hyprpaper)
M.restart = function()
  M.hypr_notify("Reloading Hyprland and Daemons", { type = NotifyType.Alert })
  hl.exec_cmd("pkill hyprpaper; hyprpaper &")
  hl.exec_cmd("hyprctl reload")
end

--- Workspace ---

---@alias WorkspaceOrientation "vertical" | "horizontal"
---@alias WorkspaceListenersTable table<string, function[]>
---@alias WorkspaceOrientationCallback fun(orientation: WorkspaceOrientation)

local workspace = {
  ---@type WorkspaceListenersTable
  listeners = {
    ---@type WorkspaceOrientationCallback[]
    orientation = {},
  },

  ---@type WorkspaceOrientation
  orientation = "horizontal",
}

---@param callback WorkspaceOrientationCallback
function workspace:on_orientation_changed(callback)
  table.insert(self.listeners.orientation, callback)
end

---@private
---@param queue string
function workspace:emit(queue, event)
  for _, callback in pairs(self.listeners[queue]) do
    callback(event)
  end
end

function workspace:toggle_orientation()
  ---@type WorkspaceOrientation
  local orientation
  if self.orientation == "vertical" then
    orientation = "horizontal"
  else
    orientation = "vertical"
  end

  self.orientation = orientation

  self:emit("orientation", orientation)

  M.hypr_notify("Workspace orientation changed to: " .. self.orientation)
end

---@param orientation WorkspaceOrientation
function workspace:set_orientation(orientation)
  if self.orientation == orientation then
    return
  end

  self.orientation = orientation
  self:emit("orientation", orientation)

  M.hypr_notify("Workspace orientation changed to: " .. self.orientation)
end

M.workspace = workspace

--- Layout ---

local DWINDLE = "dwindle"
local SCROLLING = "scrolling"

local layout = {
  ---@type "dwindle" | "scrolling" | "master"
  current = DWINDLE,
}

function layout:toggle_layout()
  if self.current == DWINDLE then
    self.current = SCROLLING
    -- change the orientation when is scrolling
    workspace:set_orientation("vertical")
  else
    self.current = DWINDLE
    -- change the orientation when is dwindle
    workspace:set_orientation("horizontal")
  end

  M.hypr_notify("Tiling Layout changed to: " .. self.current)
  hl.config({ general = { layout = self.current } })
end

function layout:toggle_split()
  if self.current == DWINDLE then
    hl.dsp.layout("togglesplit")
  else
    M.hypr_notify(
      "Can not use toggle split with " .. self.current .. " layout",
      { type = NotifyType.Warn }
    )
  end
end

M.layout = layout

return M
