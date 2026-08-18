
-- Hyprland Lua config entrypoint.
-- Hyprland loads this file directly, and we split the config into Lua modules
-- under this directory.

require("monitors")
require("environment-variables")
require("variables")
require("customization")
require("input")
require("windows-and-workspaces")
require("plugins")
require("hyprpaper")
require("autostart")
require("binds")
