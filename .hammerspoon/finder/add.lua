-- Finder key a (hammerspoon://add): asks for a name and creates it where the cursor is.
-- name = file, name/ = folder, dir/name = both. Nothing is overwritten. See ~/.config/docs/keys.md
local M = {}

local ax = require("hs.axuielement")

local function quote(text) -- for an AppleScript string
	return (text:gsub("\\", "\\\\"):gsub('"', '\\"'))
end

-- Where a new item goes: { dir = folder, column = the list that has the focus (column view only) }.
-- dir is the folder of the selected item; in a column without a selection (an empty folder) it is
-- the folder the window shows, because Finder then reports the folder itself as the selection.
-- nil where there is no folder ("Computer", search results without a selection).
function M.place()
	local app = hs.application.get("com.apple.finder")
	local focused = app and ax.applicationElement(app):attributeValue("AXFocusedUIElement")
	local column = focused and focused:attributeValue("AXRole") == "AXList" and focused or nil
	local picked = column and column:attributeValue("AXSelectedChildren")
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
	return { dir = path == "/" and path or (path:gsub("/$", "")), column = column }
end

-- What the name would create in dir, without doing it, or nil and the reason:
--   path     the new file or folder
--   folder   true when it is a folder (the name ends in /)
--   missing  folders to create on the way, outermost first
--   top      the part that sits in dir itself (of a/b.txt: a), topNew = it does not exist yet
--   text     for the prompt
function M.plan(dir, name)
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		return nil, "Type a name. End it with / for a folder"
	end
	if name:sub(1, 1) == "/" or name:find(":", 1, true) or name:find("//", 1, true) then
		return nil, "A name inside this folder, without a leading / or a :"
	end
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
	local folder = name:sub(-1) == "/"
	local text = "Create " .. (folder and "folder " or "file ") .. parts[#parts]
	if #missing > 0 then
		text = text .. " and folder " .. missing[1]:match("[^/]+$") .. (#missing > 1 and " (+" .. (#missing - 1) .. ")" or "")
	end
	local topPath = dir:gsub("/$", "") .. "/" .. parts[1]
	return {
		path = path,
		folder = folder,
		missing = missing,
		top = parts[1],
		topNew = (missing[1] or path) == topPath,
		text = text,
	}
end

-- Lets Finder create the item name in dir. Finder then shows it after about 0.3 s; an item made
-- behind its back turns up anywhere between 0.03 and 1.4 s later (measured).
local function finderMake(kind, dir, name)
	return hs.osascript.applescript(
		('tell application "Finder" to make new %s at (POSIX file "%s" as alias) with properties {name:"%s"}'):format(
			kind,
			quote(dir),
			quote(name)
		)
	)
end

-- Creates it; returns the plan that was carried out, or nil and the reason. Never overwrites.
-- The part that lands in dir itself is made by Finder (it is the one to be selected), the rest directly.
function M.create(dir, name)
	local plan, why = M.plan(dir, name)
	if not plan then
		return nil, why
	end
	if plan.topNew then
		finderMake((#plan.missing > 0 or plan.folder) and "folder" or "file", dir, plan.top)
	end
	for _, path in ipairs(plan.missing) do
		if not hs.fs.attributes(path, "mode") and not hs.fs.mkdir(path) then
			return nil, "Could not create " .. path
		end
	end
	if plan.folder then
		if not hs.fs.attributes(plan.path, "mode") and not hs.fs.mkdir(plan.path) then
			return nil, "Could not create " .. plan.path
		end
	else
		local file = io.open(plan.path, "a") -- "a" leaves the content alone should the file exist by now
		if not file then
			return nil, "Could not create " .. plan.path
		end
		file:close()
	end
	return plan
end

-- Selects the item name of place.dir without opening or raising a window.
-- Column view: in the column that had the focus. Finder needs a moment to show a new item, so this
-- looks again every 50 ms, tries times.
-- Other views: through Finder itself, which works for the folder the window shows. Not "reveal" or
-- "select": those open another window when the item is not shown. (A list, {item}, selects nothing.)
--
-- Finder may spell an umlaut differently than it was typed (two characters instead of one), so a
-- name with such letters is compared by the file it points to.
local function sameFile(dir, shown, name)
	if shown == name then
		return true
	end
	if not (shown and shown:find("[\128-\255]") and name:find("[\128-\255]")) then
		return false
	end
	local wanted = hs.fs.attributes(dir .. "/" .. name, "ino")
	return wanted ~= nil and hs.fs.attributes(dir .. "/" .. shown, "ino") == wanted
end

local selectTimer
local function select(place, name, tries)
	if not place.column then
		hs.osascript.applescript(([[
			tell application "Finder"
				set added to (POSIX file "%s" as alias)
				set selection to added
			end tell]]):format(quote(place.dir:gsub("/$", "") .. "/" .. name)))
		return
	end
	for _, row in ipairs(place.column:attributeValue("AXChildren") or {}) do
		for _, part in ipairs(row:attributeValue("AXChildren") or {}) do
			if sameFile(place.dir, part:attributeValue("AXFilename"), name) then
				place.column:setAttributeValue("AXSelectedChildren", { row })
				return
			end
		end
	end
	if tries > 0 then
		selectTimer = hs.timer.doAfter(0.05, function()
			select(place, name, tries - 1)
		end)
	end
end

-- Creates name at place and selects the part of it that sits there. Returns the plan, or nil and the reason.
function M.make(place, name)
	local plan, why = M.create(place.dir, name)
	if plan then
		select(place, plan.top, 40)
	end
	return plan, why
end

-- The prompt: a picker with one row that says what Enter will create
local place -- where the prompt was opened for
local prompt = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	local plan, why = M.make(place, choice.name)
	if not plan then
		hs.alert.show(why)
	end
end)
prompt:rows(2) -- with 1 the picker cuts its only row off
prompt:placeholderText("name, or name/ for a folder")
local function preview(query)
	local plan, why = M.plan(place.dir, query)
	local shown = place.dir:gsub("^" .. os.getenv("HOME"), "~")
	prompt:choices({ { text = plan and plan.text or why, subText = "in " .. shown, name = query } })
end
prompt:queryChangedCallback(preview)

function M.show()
	place = M.place()
	if not place then
		hs.alert.show("No folder here to add to")
		return
	end
	prompt:query("")
	preview("")
	prompt:show()
end

return M
