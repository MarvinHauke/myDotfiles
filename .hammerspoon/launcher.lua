-- Launcher. Opened by hammerspoon://launcher
-- This file is the picker: it asks the sources for rows and joins them. See ~/.config/docs/launcher.md
--   text      apps, then files and folders (opened before, recent, file tree)   launcher/apps.lua, paths.lua
--   /text     file tree only                                                    launcher/paths.lua
--   =expr     calculator                                                        launcher/calc.lua
local M = {}

local apps = require("launcher.apps")
local paths = require("launcher.paths")
local calc = require("launcher.calc")

local maxTree = 10 -- rows from the file tree at the end of the plain list
M.remember = paths.remember

local chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	if choice.calc then
		calc.open(choice)
	elseif choice.file then
		paths.open(choice)
	else
		apps.open(choice)
	end
end)

local function update(query)
	local function wanted()
		return chooser:query() == query
	end
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
		local choices = apps.rows(query)
		local recent, seen = paths.rows(query)
		for _, row in ipairs(recent) do
			choices[#choices + 1] = row
		end
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
