-- Tells Karabiner what is focused in Finder through the variable finder_editing:
-- 0 = browsing files, 1 = text field (rename, "Go to folder"), 2 = search field.
-- The single-key Finder rules (Y, G, gg) only fire on 0, Escape leaves the search on 2.
local M = {}

local ax = require("hs.axuielement")
local cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

M.editing = nil

local function publish(element)
	local role = element and element:attributeValue("AXRole")
	local now = 0
	if role == "AXTextField" or role == "AXTextArea" then
		now = element:attributeValue("AXSubrole") == "AXSearchField" and 2 or 1
	end
	if now ~= M.editing then
		M.editing = now
		hs.task.new(cli, nil, { "--set-variables", '{"finder_editing":' .. now .. "}" }):start()
	end
end

local function watch()
	local app = hs.application.get("com.apple.finder")
	if not app then
		return
	end
	local appElement = ax.applicationElement(app)
	M.observer = ax.observer.new(app:pid())
	M.observer:addWatcher(appElement, "AXFocusedUIElementChanged")
	M.observer:callback(function(_, element)
		publish(element)
	end)
	M.observer:start()
	publish(appElement:attributeValue("AXFocusedUIElement"))
end

-- Escape in the search field: leave the search completely instead of staying in an
-- empty "Searching ..." window. Called by hammerspoon://finder-escape
function M.escape()
	local app = hs.application.get("com.apple.finder")
	local win = app and app:focusedWindow()
	if win and win:title():find("^Searching ") then
		app:selectMenuItem({ "Go", "Back" })
	else
		hs.eventtap.keyStroke({}, "escape", 0)
	end
end

-- Finder gets a new process id when it is relaunched
M.appWatcher = hs.application.watcher.new(function(_, event, app)
	if event == hs.application.watcher.launched and app:bundleID() == "com.apple.finder" then
		watch()
	end
end)
M.appWatcher:start()
watch()

return M
