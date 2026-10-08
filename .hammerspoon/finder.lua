-- Tells Karabiner what is focused in Finder through the variable finder_editing:
-- 0 = browsing files, 1 = text field (rename, "Go to folder"), 2 = search field.
-- The single-key Finder rules (Y, G, gg) only fire on 0.
-- Also leaves an empty search: when focus moves out of an empty search field (Escape),
-- the window goes back to the folder instead of staying on an empty "Searching ..." view.
local M = {}

local ax = require("hs.axuielement")
local cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

M.editing = nil
local searchField

local function leaveEmptySearch()
	local value = searchField and searchField:attributeValue("AXValue")
	local app = hs.application.get("com.apple.finder")
	local win = app and app:focusedWindow()
	if (value == nil or value == "") and win and win:title():find("^Searching ") then
		app:selectMenuItem({ "Go", "Back" })
	end
end

local function publish(element)
	local role = element and element:attributeValue("AXRole")
	local now = 0
	if role == "AXTextField" or role == "AXTextArea" then
		now = element:attributeValue("AXSubrole") == "AXSearchField" and 2 or 1
	end
	if now == 2 then
		searchField = element
	end
	if now ~= M.editing then
		if M.editing == 2 then
			leaveEmptySearch()
		end
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

-- Finder gets a new process id when it is relaunched
M.appWatcher = hs.application.watcher.new(function(_, event, app)
	if event == hs.application.watcher.launched and app:bundleID() == "com.apple.finder" then
		watch()
	end
end)
M.appWatcher:start()
watch()

return M
