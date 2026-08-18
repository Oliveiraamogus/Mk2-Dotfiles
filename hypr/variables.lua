local vars = {}

-- Hyprland programs
vars.terminal = "kitty" -- alacritty
vars.fileManager = "dolphin"
vars.menu = "anyrun -c ~/.config/anyrun"
vars.browser = "zen-browser"

-- Theme colors from ~/.config/themes/current.json (colors.primary / colors.secondary)
local function themeHex(key, fallback)
  local path = (os.getenv("HOME") or "") .. "/.config/themes/current.json"
  local file = io.open(path, "r")
  if not file then
    return fallback
  end
  local content = file:read("*a")
  file:close()
  local hex = content:match('"' .. key .. '"%s*:%s*"#([0-9A-Fa-f]+)"')
  if not hex or #hex < 6 then
    return fallback
  end
  return hex:sub(1, 6)
end

local primary = themeHex("primary", "694355")
local secondary = themeHex("secondary", "30353A")

vars.MainColor = "rgb(" .. primary .. ")"
vars.SecondaryColor = "rgb(" .. secondary .. ")"
vars.MainColorRgba = "rgba(" .. primary .. "ff)"
vars.SecondaryColorRgba = "rgba(" .. secondary .. "ff)"

return vars

