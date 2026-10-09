-- Launcher: what was opened how often, and what was picked for which typed text.
-- Used by launcher.lua to rank rows of every kind. See ~/.config/docs/launcher.md
-- Stored in hs.settings under "launcher.usage":
--   items = { [id] = { n = opens, t = time of the last open, kind = "file" | "folder" | nil } }
--   picks = { [typed text] = { id = ..., t = ... } }   the favourite for exactly that text
-- id: the path of an app, file or folder; "name:<name>" for places and aliases from ~/.zshrc.
local M = {}

local day = 86400
local maxItems, maxPicks = 500, 300

local data = hs.settings.get("launcher.usage")
if not data then
	-- first start: carry over the old app counter and the list of opened paths, as "used last month"
	data = { items = {}, picks = {} }
	local old = os.time() - 8 * day
	for path, count in pairs(hs.settings.get("launcher.counts") or {}) do
		data.items[path] = { n = count, t = old }
	end
	for _, entry in ipairs(hs.settings.get("launcher.history") or {}) do
		data.items[entry.path] = { n = 1, t = old, kind = entry.kind }
	end
	hs.settings.set("launcher.usage", data)
end

function M.id(row)
	return row.named and "name:" .. row.text or row.file or row.path
end

-- opens weighted by age: last day 4x, last week 2x, last month 1x, older 0.5x
function M.score(row)
	local item = data.items[M.id(row)]
	if not item then
		return 0
	end
	local age = os.time() - item.t
	return item.n * (age < day and 4 or age < 7 * day and 2 or age < 30 * day and 1 or 0.5)
end

-- was this row the one picked last time for exactly this typed text?
function M.pickedFor(row, typed)
	local pick = data.picks[typed]
	return pick ~= nil and pick.id == M.id(row)
end

-- drops the entries with the lowest value until at most max are left
local function trim(list, max, value)
	local keys = {}
	for key in pairs(list) do
		keys[#keys + 1] = key
	end
	if #keys <= max then
		return
	end
	table.sort(keys, function(a, b)
		return value(list[a]) < value(list[b])
	end)
	for i = 1, #keys - max do
		list[keys[i]] = nil
	end
end

-- typed: the plain text that was in the input, or nil (file tree search, Tab, ...)
function M.record(row, typed)
	local id, now = M.id(row), os.time()
	local item = data.items[id] or { n = 0 }
	item.n, item.t = item.n + 1, now
	item.kind = not row.named and row.kind or nil
	data.items[id] = item
	if typed and typed ~= "" then
		data.picks[typed] = { id = id, t = now }
	end
	trim(data.items, maxItems, function(e)
		return e.n * 1e10 + e.t
	end)
	trim(data.picks, maxPicks, function(e)
		return e.t
	end)
	hs.settings.set("launcher.usage", data)
end

-- files and folders that were opened: { { path = ..., kind = ... }, ... }
function M.paths()
	local out = {}
	for id, item in pairs(data.items) do
		if item.kind then
			out[#out + 1] = { path = id, kind = item.kind }
		end
	end
	return out
end

return M
