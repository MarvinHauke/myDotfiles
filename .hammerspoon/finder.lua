-- Tells Karabiner what is focused in Finder through the variable finder_editing:
-- 0 = browsing files, 1 = text field (rename, "Go to folder"), 2 = search field.
-- The single-key Finder rules (Y, G, gg) only fire on 0.
-- A second variable, finder_first_column (0/1), says whether the leftmost column of the column view
-- has the focus: there Ctrl+h goes up to the parent folder instead of sending Left.
-- Also leaves an empty search: when focus moves out of an empty search field (Escape),
-- the window goes back to the folder instead of staying on an empty "Searching ..." view.
-- Escape twice in the search results does the same.
-- M.edit() opens the selection in nvim (hammerspoon://edit).
-- M.add() asks for a name and creates a file, or a folder when the name ends in / (hammerspoon://add).
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

-- The folder a new item goes into: the column that has the focus. That is the folder of the selected
-- item; in a column without a selection (an empty folder) it is the folder the window shows, because
-- Finder then reports the folder itself as the selection.
-- nil where there is none ("Computer", search results without a selection).
-- Second result: the element that has the focus (in column view the list of that column).
function M.folder()
	local app = hs.application.get("com.apple.finder")
	local focused = app and ax.applicationElement(app):attributeValue("AXFocusedUIElement")
	local picked = focused and focused:attributeValue("AXSelectedChildren")
	local empty = picked ~= nil and #picked == 0
	local ok, path = hs.osascript.applescript(([[
		tell application "Finder"
			set picked to (get selection)
			if %s or picked is {} then
				return POSIX path of ((target of front Finder window) as alias)
			end if
			return POSIX path of ((container of item 1 of picked) as alias)
		end tell]]):format(tostring(empty)))
	if not ok or type(path) ~= "string" then
		return nil
	end
	return path == "/" and path or (path:gsub("/$", "")), focused
end

-- What the name would create in dir, without doing it:
-- { path, folder = true for a folder, missing = folders to create first, text = for the prompt }
-- or nil and the reason. A name ending in / is a folder; a/b.txt also creates a.
function M.plan(dir, name)
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		return nil, "Type a name. End it with / for a folder"
	end
	if name:sub(1, 1) == "/" or name:find(":", 1, true) or name:find("//", 1, true) then
		return nil, "A name inside this folder, without a leading / or a :"
	end
	local folder = name:sub(-1) == "/"
	local parts = {}
	for part in name:gmatch("[^/]+") do
		if part == "." or part == ".." then
			return nil, ". and .. are not allowed"
		end
		parts[#parts + 1] = part
	end
	local path, missing = dir:gsub("/$", ""), {}
	for i, part in ipairs(parts) do
		path = path .. "/" .. part
		local mode = hs.fs.attributes(path, "mode")
		if i == #parts then
			if mode then
				return nil, part .. " already exists"
			end
		elseif not mode then
			missing[#missing + 1] = path
		elseif mode ~= "directory" then
			return nil, part .. " is a file, not a folder"
		end
	end
	local text = "Create " .. (folder and "folder " or "file ") .. parts[#parts]
	if #missing > 0 then
		text = text .. " and folder " .. missing[1]:match("[^/]+$") .. (#missing > 1 and " (+" .. (#missing - 1) .. ")" or "")
	end
	return { path = path, folder = folder, missing = missing, text = text }
end

-- Creates it; returns the new path, or nil and the reason. Never overwrites.
function M.create(dir, name)
	local plan, why = M.plan(dir, name)
	if not plan then
		return nil, why
	end
	for _, path in ipairs(plan.missing) do
		if not hs.fs.mkdir(path) then
			return nil, "Could not create " .. path
		end
	end
	if plan.folder then
		if not hs.fs.mkdir(plan.path) then
			return nil, "Could not create " .. plan.path
		end
	else
		local file = io.open(plan.path, "a") -- "a" leaves the content alone should the file appear meanwhile
		if not file then
			return nil, "Could not create " .. plan.path
		end
		file:close()
	end
	return plan.path
end

-- Selects an item of the folder the front window shows (list and icon view).
-- Not "reveal" or "select": those open another window when the front one does not show the item,
-- this does nothing then. (A list, {item}, selects nothing.)
function M.select(path)
	local quoted = path:gsub("\\", "\\\\"):gsub('"', '\\"')
	return hs.osascript.applescript(([[
		tell application "Finder"
			set added to (POSIX file "%s" as alias)
			set selection to added
		end tell]]):format(quoted))
end

-- Selects the new item name in the column it was made in. Finder needs a moment to show a new
-- item, so this looks again a few times. Stays in that column: no window is opened or raised.
local function selectIn(list, dir, name, tries)
	if not list or list:attributeValue("AXRole") ~= "AXList" then
		M.select(dir:gsub("/$", "") .. "/" .. name) -- not the column view
		return
	end
	for _, row in ipairs(list:attributeValue("AXChildren") or {}) do
		for _, part in ipairs(row:attributeValue("AXChildren") or {}) do
			if part:attributeValue("AXFilename") == name then
				list:setAttributeValue("AXSelectedChildren", { row })
				return
			end
		end
	end
	if tries > 0 then
		hs.timer.doAfter(0.2, function()
			selectIn(list, dir, name, tries - 1)
		end)
	end
end

-- Creates name in dir and selects it in list (the column that had the focus).
-- Of a/b.txt the part that sits in this folder is selected: a
function M.make(dir, list, name)
	local path, why = M.create(dir, name)
	if path then
		selectIn(list, dir, path:sub(#dir:gsub("/$", "") + 2):match("[^/]+"), 15)
	end
	return path, why
end

-- The prompt: a picker with one row that says what Enter will create
local addDir, addList -- folder and focused column of the window the prompt was opened for
local adder = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	local path, why = M.make(addDir, addList, choice.name)
	if not path then
		hs.alert.show(why)
	end
end)
adder:rows(2) -- with 1 the picker cuts its only row off
adder:placeholderText("name, or name/ for a folder")
local function preview(query)
	local plan, why = M.plan(addDir, query)
	local shown = addDir:gsub("^" .. os.getenv("HOME"), "~")
	adder:choices({ { text = plan and plan.text or why, subText = "in " .. shown, name = query } })
end
adder:queryChangedCallback(preview)

function M.add()
	local dir, focused = M.folder()
	if not dir then
		hs.alert.show("No folder here to add to")
		return
	end
	addDir, addList = dir, focused
	adder:query("")
	preview("")
	adder:show()
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
