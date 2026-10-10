-- Hammerspoon only provides actions. All hotkeys live in Karabiner and call
-- them with: open -g hammerspoon://<action>   (see ~/.config/docs/keys.md)
require("hs.ipc") -- enables the `hs` command line tool

local launcher = require("launcher")
local windows = require("windows")
local clipboard = require("clipboard")
local finder = require("finder") -- tells Karabiner what is focused in Finder, leaves empty searches
local finderAdd = require("finder.add")
local help = require("help")
require("capture") -- copies the path of each new screenshot in /tmp/shots

hs.urlevent.bind("launcher", function(_, params)
	launcher.toggle(params.q) -- ?q=/ starts in the file search
end)
hs.urlevent.bind("clipboard", function()
	clipboard.toggle()
end)
hs.urlevent.bind("win", function(_, params)
	windows.place(params.pos)
end)
hs.urlevent.bind("edit", function()
	finder.edit()
end)
hs.urlevent.bind("add", function()
	finderAdd.show()
end)
hs.urlevent.bind("help", function(_, params)
	help.toggle(params.topic)
end)
hs.urlevent.bind("reload", function()
	hs.reload()
end)
hs.urlevent.bind("appname", function()
	hs.alert.show(hs.application.frontmostApplication():name())
end)

hs.alert.show("Config loaded")
