------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080",
    position = "0x0",
    scale    = "1.0",
})

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "auto-right",
    scale    = "1.25",
})
