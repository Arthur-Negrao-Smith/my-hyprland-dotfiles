local state = require("config.state")

hl.config({
  general = {
    -- distance between windows
    gaps_in = 5,
    -- distance between window and borders
    gaps_out = 20,

    border_size = 2,
    layout = state.layout.current,
  },

  input = {
    touchpad = {
      -- inverts the scroll to follow the fingers movement
      natural_scroll = true,
    },

    -- inverts the scroll to follow the fingers movement
    natural_scroll = false,
    kb_layout = "br,us",
    kb_variant = "abnt2,",
  },

  xwayland = {
    force_zero_scaling = true,
  },
})
