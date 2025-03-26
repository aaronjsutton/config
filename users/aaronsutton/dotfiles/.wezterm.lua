local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.color_scheme = 'Rosé Pine (base16)'
 
config.font = wezterm.font 'JetBrains Mono Medium'

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

config.window_decorations = "RESIZE"

config.default_prog = { '/usr/local/bin/fish', '-l' }
config.default_cursor_style = "BlinkingBar"
config.font_size = 13.3

config.leader = { key="b", mods="CTRL" }
config.native_macos_fullscreen_mode = true
config.adjust_window_size_when_changing_font_size = false
config.front_end = "WebGpu"

config.animation_fps = 10
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'EaseIn'
config.cursor_blink_ease_out = 'EaseOut'

wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  local symbol
  if name == "resize_pane" then
    symbol = '󰩨 '
  end
  window:set_right_status((symbol or '') .. ' ')
end)

config.keys = {
  {
    key = 'f',
    mods = 'CMD|CTRL',
    action = act.ToggleFullScreen
  },

  {
    key = 'r',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },

  {
    key = 'b',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'activate_pane',
      timeout_milliseconds = 1000,
    },
  },

  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

  { key = '%', mods = 'LEADER', action = act.SplitHorizontal },
  { key = '\"', mods = 'LEADER', action = act.SplitVertical },

  { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },

  { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },

  { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
}

config.key_tables = {
  resize_pane = {
    { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },

    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },

    { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },

    { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },

    { key = 'Escape', action = 'PopKeyTable' },
  },
}

return config
