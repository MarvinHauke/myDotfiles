-- General Hotkeys
hs.hotkey.bind({ "cmd", "ctrl" }, "R", function()
	hs.reload()
end)
hs.alert.show("Config loaded")

hs.hotkey.bind({ "cmd" }, "i", function()
	local app = hs.application.frontmostApplication()
	hs.alert.show(app:name())
end)

--Ableton hotkeys
require("ableton")
require("ableton_cmd")
