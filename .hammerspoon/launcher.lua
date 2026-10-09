-- Launcher. Opened by hammerspoon://launcher
-- This file is the picker: it asks the sources for rows and joins them. See ~/.config/docs/launcher.md
--   text      apps, files and folders, ordered by match and by use (launcher/usage.lua), then the file tree
--   /text     file tree only                                                    launcher/paths.lua
--   =expr     calculator                                                        launcher/calc.lua
local M = {}

local apps = require("launcher.apps")
local paths = require("launcher.paths")
local calc = require("launcher.calc")
local usage = require("launcher.usage")

local maxTree = 10 -- rows from the file tree at the end of the plain list
local typed -- the plain text in the input, lower case; nil while "/" or "=" is used

local chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	if choice.calc then
		calc.open(choice)
		return
	end
	usage.record(choice, typed)
	if choice.file then
		paths.open(choice)
	else
		apps.open(choice)
	end
end)

-- Rows of every kind in one order:
--   1. the row picked last time for exactly this text
--   2. by match rank (name starts with the text > name contains it > path or scattered letters)
--   3. by use, 4. apps, places, folders, files, 5. the order the source gave
local function ranked(query)
	local rows = apps.rows(query)
	local found, seen = paths.rows(query)
	for _, row in ipairs(found) do
		rows[#rows + 1] = row
	end
	for i, row in ipairs(rows) do
		row.fav, row.use, row.i = usage.pickedFor(row, typed), usage.score(row), i
	end
	table.sort(rows, function(a, b)
		if a.fav ~= b.fav then
			return a.fav
		end
		if a.rank ~= b.rank then
			return a.rank < b.rank
		end
		if a.use ~= b.use then
			return a.use > b.use
		end
		if a.group ~= b.group then
			return a.group < b.group
		end
		return a.i < b.i
	end)
	return rows, seen
end

local function update(query)
	local function wanted()
		return chooser:query() == query
	end
	typed = nil
	if query:sub(1, 1) == "=" then
		chooser:choices(calc.rows(query:sub(2)))
	elseif query:sub(1, 1) == "/" then
		if #query > 1 then
			paths.search(query:sub(2), 40, wanted, function(rows)
				chooser:choices(rows)
			end)
		else
			chooser:choices({})
		end
	else
		typed = query:lower()
		local choices, seen = ranked(query)
		chooser:choices(choices)
		-- from 3 characters on, matches from the whole file tree follow at the end
		if #query >= 3 then
			paths.search(query, maxTree + #choices, wanted, function(rows)
				local added = 0
				for _, row in ipairs(rows) do
					if added < maxTree and not seen[row.file] then
						choices[#choices + 1] = row
						added = added + 1
					end
				end
				if added > 0 then
					chooser:choices(choices)
				end
			end)
		else
			paths.cancel()
		end
	end
end
chooser:queryChangedCallback(update)

-- Keys the picker does not handle itself. Only listens while the launcher is open.
-- Tab: writes the highlighted app name into the input; on a folder its path, to search below it.
-- Cmd+Enter: shows the highlighted file or folder in Finder.
local tabTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local key, flags = event:getKeyCode(), event:getFlags()
	local row = chooser:selectedRowContents()
	if key == hs.keycodes.map["return"] and flags:containExactly({ "cmd" }) then
		if row and row.file then
			chooser:hide()
			usage.record(row, typed)
			paths.reveal(row)
		end
		return true
	end
	if key ~= hs.keycodes.map.tab or next(flags) then
		return false
	end
	if row and row.path then
		chooser:query(row.text)
		update(row.text)
	elseif row and row.kind == "folder" then
		local below = paths.below(row)
		chooser:query(below)
		update(below)
	end
	return true
end)
chooser:showCallback(function()
	tabTap:start()
end)
chooser:hideCallback(function()
	tabTap:stop()
end)

-- query: text to start with, e.g. "/" for the file search (hammerspoon://launcher?q=/)
function M.toggle(query)
	if chooser:isVisible() then
		chooser:hide()
		return
	end
	apps.refresh()
	paths.refresh()
	chooser:query(query or "")
	update(query or "")
	chooser:show()
end

return M
