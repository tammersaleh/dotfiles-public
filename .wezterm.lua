local wezterm = require 'wezterm'
local act = wezterm.action

return {
  font = wezterm.font('Fira Code'),
  font_size = 18,
  window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  },
  -- color_scheme = 'Batman',

  cursor_blink_rate = 500,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
  default_cursor_style = "BlinkingBlock",

  window_frame = {
    -- font = wezterm.font({ family = "Cascadia Code Semibold" }),
    font = wezterm.font('Fira Code'),

    -- The size of the font in the tab bar.
    -- Default to 10. on Windows but 12.0 on other systems
    font_size = 15.0,

    active_titlebar_bg   = "#333333",
    inactive_titlebar_bg = "#333333",
    -- inactive_tab_edge    = "#575757",

    border_left_width    = '1',
    border_right_width   = '1',
    border_bottom_height = '1',
    border_top_height    = '1',
    border_left_color    = 'darkgray',
    border_right_color   = 'darkgray',
    border_bottom_color  = 'darkgray',
    border_top_color     = 'darkgray',
  },
  hide_tab_bar_if_only_one_tab = true,
  quit_when_all_windows_are_closed = false,

  disable_default_key_bindings = true,

  keys = {
    { key = 'd', mods = 'CMD|OPT', action = act.ShowDebugOverlay },
    { key = 'r', mods = 'CMD|OPT', action = act.ReloadConfiguration },

    { key = 'q', mods = 'CMD', action = act.QuitApplication },
    { key = 'w', mods = 'CMD', action = act.CloseCurrentTab{ confirm = true } },
    { key = 'n', mods = 'CMD', action = act.SpawnWindow },
    { key = 't', mods = 'CMD', action = act.SpawnTab 'DefaultDomain' },

    { key = '1', mods = 'CMD', action = act.ActivateTab(0) },
    { key = '2', mods = 'CMD', action = act.ActivateTab(1) },
    { key = '3', mods = 'CMD', action = act.ActivateTab(2) },
    { key = '4', mods = 'CMD', action = act.ActivateTab(4) },
    { key = '5', mods = 'CMD', action = act.ActivateTab(5) },
    { key = '6', mods = 'CMD', action = act.ActivateTab(6) },
    { key = '7', mods = 'CMD', action = act.ActivateTab(7) },
    { key = '8', mods = 'CMD', action = act.ActivateTab(8) },
    { key = '9', mods = 'CMD', action = act.ActivateTab(9) },

    { key = '{', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = '}', mods = 'CMD|SHIFT', action = act.ActivateTabRelative(1) },

    { key = 'Enter', mods = 'CMD|SHIFT', action = act.ToggleFullScreen },

    { key = '=', mods = 'CMD', action = act.IncreaseFontSize },
    { key = '-', mods = 'CMD', action = act.DecreaseFontSize },
    { key = '0', mods = 'CMD', action = act.ResetFontSize },

    { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CMD', action = act.PasteFrom 'Clipboard' },
    -- { key = 'x', mods = 'CMD', action = act.ActivateCopyMode },
    -- { key = 'f', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },
    -- { key = 'e', mods = 'CMD', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
    -- { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
    -- { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
  },
}

