-- Tells Karabiner what is focused in Finder through the variable finder_editing:
-- 0 = browsing files, 1 = text field (rename, "Go to folder"), 2 = search field.
-- The single-key Finder rules (Y, G, gg) only fire on 0.
-- A second variable, finder_first_column (0/1), says whether the leftmost column of the column view
-- has the focus: there Ctrl+h goes up to the parent folder instead of sending Left.
-- Also leaves an empty search: when focus moves out of an empty search field (Escape),
-- the window goes back to the folder instead of staying on an empty "Searching ..." view.
-- Escape twice in the search results does the same.
-- M.edit() opens the selection in nvim (hammerspoon://edit).
local M = {}

local ax = require("hs.axuielement")
local cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

M.editing = nil
M.firstColumn = nil
local searchField

-- back to the folder the search was started from
local function leaveSearch()
	local app = hs.application.get("com.apple.finder")
	local win = app and app:focusedWindow()
	if win and win:title():find("^Searching ") then
		app:selectMenuItem({ "Go", "Back" })
	end
end

local function leaveEmptySearch()
	local value = searchField and searchField:attributeValue("AXValue")
	if value == nil or value == "" then
		leaveSearch()
	end
end

-- Escape twice within half a second while the result list has focus. Done here and not in
-- Karabiner, because Karabiner rules never see the Escape that a Caps Lock tap produces.
local lastEscape = 0
M.escapeTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	if event:getKeyCode() ~= hs.keycodes.map.escape then
		return false
	end
	if event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) ~= 0 then
		return false
	end
	local now = hs.timer.secondsSinceEpoch()
	if M.editing == 0 and now - lastEscape < 0.5 then
		lastEscape = 0
		hs.timer.doAfter(0, leaveSearch)
	else
		lastEscape = now
	end
	return false
end)

-- is this the file list of the leftmost column? (list > column > columns > browser)
function M.isFirstColumn(element)
	if not element or element:attributeValue("AXRole") ~= "AXList" then
		return false
	end
	local column = element:attributeValue("AXParent")
	local columns = column and column:attributeValue("AXParent")
	local browser = columns and columns:attributeValue("AXParent")
	if not browser or browser:attributeValue("AXRole") ~= "AXBrowser" then
		return false
	end
	return (columns:attributeValue("AXChildren") or {})[1] == column
end

local function publish(element)
	local role = element and element:attributeValue("AXRole")
	local now = 0
	local first = M.isFirstColumn(element) and 1 or 0
	if role == "AXTextField" or role == "AXTextArea" then
		now = element:attributeValue("AXSubrole") == "AXSearchField" and 2 or 1
	end
	if now == 2 then
		searchField = element
	end
	if now ~= M.editing or first ~= M.firstColumn then
		if M.editing == 2 and now ~= 2 then
			leaveEmptySearch()
		end
		M.editing, M.firstColumn = now, first
		local vars = '{"finder_editing":' .. now .. ',"finder_first_column":' .. first .. "}"
		hs.task.new(cli, nil, { "--set-variables", vars }):start()
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

-- Opens the selected files and folders with ~/.local/bin/edit (nvim inside tmux)
function M.edit()
	local ok, paths = hs.osascript.applescript([[
		tell application "Finder"
			set out to {}
			repeat with f in (get selection as alias list)
				set end of out to POSIX path of f
			end repeat
			return out
		end tell]])
	if ok and type(paths) == "table" and #paths > 0 then
		hs.task.new(os.getenv("HOME") .. "/.local/bin/edit", nil, paths):start()
	end
end

-- Finder gets a new process id when it is relaunched; the Escape listener only runs while Finder is in front
M.appWatcher = hs.application.watcher.new(function(_, event, app)
	if app:bundleID() ~= "com.apple.finder" then
		return
	end
	if event == hs.application.watcher.launched then
		watch()
	elseif event == hs.application.watcher.activated then
		M.escapeTap:start()
	elseif event == hs.application.watcher.deactivated then
		M.escapeTap:stop()
	end
end)
M.appWatcher:start()
watch()
if hs.application.frontmostApplication():bundleID() == "com.apple.finder" then
	M.escapeTap:start()
end

return M
