-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Apply font and window options
config.front_end = "OpenGL"
config.max_fps = 60
config.animation_fps = 60

config.font = wezterm.font("FiraCode Nerd Font")
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.font_size = 10
config.window_background_opacity = 0.55
config.win32_system_backdrop = "Acrylic"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Color schemes setup
config.color_schemes = {
	["Campbell"] = {
		foreground = "#CCCCCC",
		background = "#0C0C0C",
		cursor_bg = "#FFFFFF",
		cursor_fg = "#0C0C0C",
		selection_bg = "#FFFFFF",
		selection_fg = "#0C0C0C",
		ansi = { "#0C0C0C", "#C50F1F", "#13A10E", "#C19C00", "#0037DA", "#881798", "#3A96DD", "#CCCCCC" },
		brights = { "#767676", "#E74856", "#16C60C", "#F9F1A5", "#3B78FF", "#B4009E", "#61D6D6", "#F2F2F2" },
	},
}

-- Specify default program for starting terminal
config.default_prog = { "pwsh.exe", "-NoLogo" }
config.default_cursor_style = "SteadyBlock"

-- Keybindings
config.keys = {
	{ key = "C", mods = "CTRL", action = wezterm.action.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "V", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
}

-- Set environment variables
config.set_environment_variables = {}

-- Define profiles
config.launch_menu = {
	{
		label = "Windows PowerShell",
		args = { "powershell.exe" },
	},
	{
		label = "Command Prompt",
		args = { "cmd.exe" },
	},
	{
		label = "Ubuntu",
		args = { "wsl", "-d", "Ubuntu" },
	},
	{
		label = "Git Bash",
		args = { "C:/Program Files/Git/bin/bash.exe", "--login", "-i" },
	},
}

-- Finally, return the configuration to wezterm
return config
