-- Input configuration

hl.config({
  input = {
    kb_layout = "pt",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,
    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      clickfinger_behavior = true,
      natural_scroll = false,
    },
  },
})

-- Gestures (previously gesture = 3, horizontal, workspace)
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

-- Per-device config (previously device { name = epic-mouse-v1 ... })
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

