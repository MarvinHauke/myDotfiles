-- Finder helpers. Called by hammerspoon://finder-yank
local M = {}

local ax = require("hs.axuielement")

-- true while renaming a file or typing in a search field
local function editingText()
	local element = ax.systemWideElement():attributeValue("AXFocusedUIElement")
	local role = element and element:attributeValue("AXRole")
	return role == "AXTextField" or role == "AXTextArea"
end

-- Copy the path of the selection (or of the open folder), like Y in vim.
-- Uses Finder's own "Copy as Pathname" (Opt+Cmd+C).
function M.yank()
	if editingText() then
		hs.eventtap.keyStrokes("Y")
		return
	end
	hs.eventtap.keyStroke({ "alt", "cmd" }, "c")
	hs.timer.doAfter(0.2, function()
		hs.alert.show(hs.pasteboard.getContents() or "nothing copied")
	end)
end

return M
