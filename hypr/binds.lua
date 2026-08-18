-- Keybinds

local vars = require("variables")

local mainMod = "SUPER"

local function mod(key)
  return mainMod .. " + " .. key
end

local function modShift(key)
  return mainMod .. " + SHIFT + " .. key
end

-- Programs from variables.conf
local terminal = vars.terminal
local fileManager = vars.fileManager
local menu = vars.menu
local browser = vars.browser

-- Example binds
hl.bind(mod("Q"), hl.dsp.exec_cmd(terminal))
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(
  mod("M"),
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mod("E"), hl.dsp.exec_cmd(fileManager))
hl.bind(mod("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod("R"), hl.dsp.exec_cmd(menu))
hl.bind(mod("P"), hl.dsp.window.pseudo())
hl.bind(mod("J"), hl.dsp.layout("togglesplit")) -- dwindle only

-- Custom
hl.bind(mod("F"), hl.dsp.exec_cmd(browser))

-- Volume and media control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -m"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, repeating = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, repeating = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, repeating = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Custom

-- Clip history picker
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- Hyprland lua bind parser uses key names directly; the conf had: "bind = , F11, fullscreen,"
-- so we add a correct version without modifiers:
hl.bind("F11", hl.dsp.window.fullscreen())

-- Screen shots
hl.bind("print", hl.dsp.exec_cmd([[grim -g "$(slurp)" -t jpeg -q 100]]))
hl.bind("SHIFT + print", hl.dsp.exec_cmd([[grim -g "0,0 1920x1080" -t jpeg -q 100]]))

-- Gaps/border toggles: F11 hides chrome, F12 restores it.
-- Same idea as binds.conf (zero gaps/borders/rounding and kill the bar),
-- but via hl.config() so it works under Lua, and targeting quickshell.
local function setChrome(opts)
  hl.config({
    general = {
      gaps_in = opts.gaps_in,
      gaps_out = opts.gaps_out,
      border_size = opts.border_size,
    },
    decoration = {
      rounding = opts.rounding,
    },
  })
end

hl.bind(mod("F11"), function()
  setChrome({ gaps_in = 0, gaps_out = 0, border_size = 0, rounding = 0 })
  hl.exec_cmd("pkill quickshell")
end)

hl.bind(mod("F12"), function()
  setChrome({ gaps_in = 3, gaps_out = 4, border_size = 2, rounding = 10 })
  hl.exec_cmd("quickshell --path ~/.config/quickshell/shell.qml")
end)

-- Theme switching
hl.bind(mod("F3"), hl.dsp.exec_cmd("/home/manel/.config/scripts/selector.sh darkred"))
hl.bind(mod("F4"), hl.dsp.exec_cmd("/home/manel/.config/scripts/selector.sh red"))
hl.bind(mod("F5"), hl.dsp.exec_cmd("/home/manel/.config/scripts/selector.sh gren"))
hl.bind(mod("F6"), hl.dsp.exec_cmd("/home/manel/.config/scripts/selector.sh blu"))

-- Move focus with mainMod + arrow keys
hl.bind(mod("left"), hl.dsp.focus({ direction = "l" }))
hl.bind(mod("right"), hl.dsp.focus({ direction = "r" }))
hl.bind(mod("up"), hl.dsp.focus({ direction = "u" }))
hl.bind(mod("down"), hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
  hl.bind(mod(tostring(i)), hl.dsp.focus({ workspace = i }))
end
hl.bind(mod("0"), hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
  hl.bind(modShift(tostring(i)), hl.dsp.window.move({ workspace = i }))
end
hl.bind(modShift("0"), hl.dsp.window.move({ workspace = 10 }))

-- Example special workspace (scratchpad)
hl.bind(mod("S"), hl.dsp.workspace.toggle_special("magic"))
hl.bind(modShift("S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mod("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod("mouse_up"), hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mod("mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(mod("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- overview plugin
hl.bind(mod("Tab"), hl.dsp.exec_cmd("overview:toggle"))

