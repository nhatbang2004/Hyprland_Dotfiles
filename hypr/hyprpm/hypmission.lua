-- config 
hl.config({
    plugin = {
        hymission = {
            outer_padding_top = 92,
            layout_engine = "grid",
            niri_mode = 0,
            switch_release_key = "Super_L",
            workspace_strip_anchor = "top",
	    
        },
    },
})


-- Keybindings --
hl.bind("SUPER + TAB", hl.plugin.hymission.toggle)
hl.bind("SUPER + A", function()
    hl.plugin.hymission.toggle("forceall")
end)
hl.bind("SUPER + SHIFT + TAB", function()
    hl.plugin.hymission.open("onlycurrentworkspace")
end)
hl.bind("SUPER + Escape", hl.plugin.hymission.close)


hl.plugin.hymission.gesture({
    fingers = 3,
    direction = "vertical",
    action = "toggle",
    args = "forceall",
})

hl.plugin.hymission.gesture({
    fingers = 3,
    direction = "vertical",
    action = "toggle",
    recommand = true,
})

hl.plugin.hymission.gesture({
    fingers = 4,
    direction = "vertical",
    action = "open",
    scope = "onlycurrentworkspace",
})

