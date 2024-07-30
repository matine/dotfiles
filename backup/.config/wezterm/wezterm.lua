-- Pull in the wezterm API
local wezterm = require "wezterm"

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Macchiato"
config.font = monospace
config.font_size = 14
config.line_height = 1.3
config.command_palette_rows = 16

-- tmux
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

-- See default keys here: https://wezfurlong.org/wezterm/config/default-keys.html?h=keys
-- See key assignments here: https://wezfurlong.org/wezterm/config/keys.html#configuring-key-assignments
config.keys = {
    {
        mods = "CMD",
        key = "n",
        action = wezterm.action.SpawnTab "CurrentPaneDomain",
    },
    {
        mods = 'CMD',
        key = 'w',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },
    {
        mods = "SHIFT",
        key = "LeftArrow",
        action = wezterm.action.ActivatePaneDirection "Left"
    },
    {
        mods = "SHIFT",
        key = "DownArrow",
        action = wezterm.action.ActivatePaneDirection "Down"
    },
    {
        mods = "SHIFT",
        key = "UpArrow",
        action = wezterm.action.ActivatePaneDirection "Up"
    },
    {
        mods = "SHIFT",
        key = "RightArrow",
        action = wezterm.action.ActivatePaneDirection "Right"
    },
    {
      mods = "LEADER",
      key = "\\",
      action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
    {
        mods = "LEADER",
        key = "-",
        action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    {
        mods = "LEADER",
        key = "LeftArrow",
        action = wezterm.action.AdjustPaneSize { "Left", 5 }
    },
    {
        mods = "LEADER",
        key = "RightArrow",
        action = wezterm.action.AdjustPaneSize { "Right", 5 }
    },
    {
        mods = "LEADER",
        key = "DownArrow",
        action = wezterm.action.AdjustPaneSize { "Down", 5 }
    },
    {
        mods = "LEADER",
        key = "UpArrow",
        action = wezterm.action.AdjustPaneSize { "Up", 5 }
    },
}

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-- tmux status
wezterm.on("update-right-status", function(window, _)
    local SOLID_LEFT_ARROW = ""
    local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
    local prefix = ""

    if window:leader_is_active() then
        prefix = " " .. utf8.char(0x1f30a) -- ocean wave
        SOLID_LEFT_ARROW = utf8.char(0xe0b2)
    end

    if window:active_tab():tab_id() ~= 0 then
        ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
    end -- arrow color based on if tab is first pane

    window:set_left_status(wezterm.format {
        { Background = { Color = "#b7bdf8" } },
        { Text = prefix },
        ARROW_FOREGROUND,
        { Text = SOLID_LEFT_ARROW }
    })
end)

-- and finally, return the configuration to wezterm
return config