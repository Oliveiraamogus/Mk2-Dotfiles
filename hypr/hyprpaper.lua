-- Hyprpaper configuration driven via Hyprland Lua.
-- This replaces most of what used to be in `hyprpaper.conf` using:
--   - `hyprctl hyprpaper preload ...`
--   - `hyprctl hyprpaper wallpaper ...`
--
-- Wallpaper is taken from the last selected theme in
-- `~/.config/themes/current.json` (the `id` field), matching
-- `~/.config/Assets/Wallpapers/<id>.*` the same way as selector.sh.

local home = os.getenv("HOME") or "~"
local wallpapersDir = home .. "/.config/Assets/Wallpapers"
local themeFile = home .. "/.config/themes/current.json"
local fallbackWallpaper = wallpapersDir .. "/gren.png"

local function readFile(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function currentThemeId()
  local content = readFile(themeFile)
  if not content then
    return nil
  end
  return content:match('"id"%s*:%s*"([^"]+)"')
end

-- Any extension matching the theme id (case-insensitive), like selector.sh.
local function findThemeWallpaper(themeId)
  if not themeId or themeId == "" then
    return nil
  end

  local handle = io.popen(string.format(
    'bash -c \'shopt -s nullglob nocaseglob; files=("%s/%s".*); printf "%%s" "${files[0]}"\'',
    wallpapersDir,
    themeId
  ))
  if not handle then
    return nil
  end
  local path = handle:read("*a")
  handle:close()
  if path and path ~= "" then
    return path
  end
  return nil
end

hl.on("hyprland.start", function()
  -- Wrap in pcall so a failure here doesn't prevent other `hyprland.start`
  -- callbacks (like quickshell) from running.
  pcall(function()
    local wallpaper = findThemeWallpaper(currentThemeId()) or fallbackWallpaper

    -- Start the daemon separately so it outlives the setup script.
    hl.exec_cmd("hyprpaper")

    -- hl.exec_cmd is async: if we wallpaper immediately, hyprpaper's IPC is
    -- not up yet and the screen stays black. Wait until the current image
    -- preloads, set it, then preload the rest for theme switching.
    hl.exec_cmd(string.format(
      [=[sh -c 'wallpaper=$1; dir=$2
        i=0
        while [ "$i" -lt 50 ]; do
          hyprctl hyprpaper preload "$wallpaper" >/dev/null 2>&1 && break
          i=$((i + 1))
          sleep 0.1
        done
        hyprctl hyprpaper wallpaper ",$wallpaper"
        for f in "$dir"/*; do
          [ -f "$f" ] || continue
          [ "$f" = "$wallpaper" ] && continue
          hyprctl hyprpaper preload "$f"
        done' _ %s %s]=],
      "'" .. wallpaper:gsub("'", "'\\''") .. "'",
      "'" .. wallpapersDir:gsub("'", "'\\''") .. "'"
    ))
  end)
end)
