-- Hammerspoon only provides actions. All hotkeys live in Karabiner and call
-- them with: open -g hammerspoon://<action>   (see ~/.config/docs/keys.md)
require("hs.ipc") -- enables the `hs` command line tool

local launcher = require("launcher")
local windows = require("windows")
local clipboard = require("clipboard")
require("finder") -- publishes finder_editing to Karabiner, leaves empty searches

hs.urlevent.bind("launcher", function()
	launcher.toggle()
end)
hs.urlevent.bind("clipboard", function()
	clipboard.toggle()
end)
hs.urlevent.bind("win", function(_, params)
	windows.place(params.pos)
end)
hs.urlevent.bind("reload", function()
	hs.reload()
end)
hs.urlevent.bind("appname", function()
	hs.alert.show(hs.application.frontmostApplication():name())
end)

hs.alert.show("Config loaded")
