-- Autostart

local vars = require("variables")
local home = os.getenv("HOME") or "~"

hl.on("hyprland.start", function()
  hl.exec_cmd("anyrun daemon")

  hl.exec_cmd(vars.terminal)

  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("quickshell --path ~/.config/quickshell/shell.qml")
  hl.exec_cmd("hyprpolkitagent")

  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  hl.exec_cmd("hyprctl plugin load ~/.Downloads/Hyprspace/Hyprspace.so")

  hl.exec_cmd("~/.config/scripts/on_startup.sh")
end)

