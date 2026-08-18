-- Monitor configuration (previously monitors.conf)

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
})

-- HDMI output
hl.monitor({
  output = "HDMI-A-1",
  mode = "highrr",
  position = "auto-right",
  scale = "auto",
})

