-- Tells Karabiner whether a text field is being edited in Finder (rename, search,
-- "Go to folder"). The single-key Finder rules (Y, G, gg) check the Karabiner
-- variable finder_editing and only fire while browsing files.
local M = {}

local ax = require("hs.axuielement")
local cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

M.editing = nil

local function publish(element)
	local role = element and element:attributeValue("AXRole")
	local now = (role == "AXTextField" or role == "AXTextArea") and 1 or 0
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

-- Finder gets a new process id when it is relaunched
M.appWatcher = hs.application.watcher.new(function(_, event, app)
	if event == hs.application.watcher.launched and app:bundleID() == "com.apple.finder" then
		watch()
	end
end)
M.appWatcher:start()
watch()

return M
