hl.config({
  general = {
    col = {
      active_border = {
        colors = { "rgba(33ccffee)" },
        {
          "rgba(00ff99ee) 45deg",
        },
      },
      inactive_border = {
        colors = { "rgba(595959aa)" },
      },
    },
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,

    dim_inactive = false,

    blur = {
      enabled = true,
      size = 15,
      passes = 3,
      ignore_opacity = true,

      noise = 0.08,
      contrast = 1.5,

      new_optimizations = true,
      xray = true,
    },

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },

    inactive_opacity = 0.8,
    active_opacity = 1.0,
  },
})
