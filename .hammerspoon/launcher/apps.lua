-- Launcher source: applications. Rows are ranked by match quality, then by how often they were started.
local M = {}

local dirs = {
	"/Applications",
	os.getenv("HOME") .. "/Applications",
	"/System/Applications",
	"/System/Library/CoreServices/Applications",
}
local apps, scannedAt = {}, 0
local counts = hs.settings.get("launcher.counts") or {}

local function scan()
	local found, seen = {}, {}
	local function add(path, folder)
		local file = path:match("([^/]+)%.app$")
		if seen[file] then
			return
		end
		seen[file] = true
		local shown = (hs.fs.displayName(path) or file):gsub("%.app$", "")
		found[#found + 1] = {
			text = shown,
			subText = path,
			path = path,
			-- folder: "Traktor Pro 3" holds an app that is only called "Traktor"
			match = (shown .. " " .. file .. (folder and " " .. folder or "")):lower(),
			image = hs.image.iconForFile(path),
		}
	end
	-- folder is the name of the subfolder dir, nil for the app folders themselves
	local function walk(dir, depth, folder)
		local ok, iter, state = pcall(hs.fs.dir, dir)
		if not ok then
			return
		end
		for entry in iter, state do
			local path = dir .. "/" .. entry
			if entry:sub(1, 1) == "." then
				-- skip
			elseif entry:sub(-4) == ".app" then
				add(path, folder)
			elseif depth > 0 and hs.fs.attributes(path, "mode") == "directory" then
				walk(path, depth - 1, entry)
			end
		end
	end
	for _, dir in ipairs(dirs) do
		walk(dir, 3) -- some vendors nest: Native Instruments/Traktor Pro 3/Traktor.app
	end
	add("/System/Library/CoreServices/Finder.app")
	apps, scannedAt = found, os.time()
end

-- 1 = prefix, 2 = word prefix, 3 = substring, 4 = letters in order, nil = no match
function M.score(name, q)
	if name:sub(1, #q) == q then
		return 1
	end
	if name:find(" " .. q, 1, true) then
		return 2
	end
	if name:find(q, 1, true) then
		return 3
	end
	local pos = 1
	for c in q:gmatch(".") do
		pos = name:find(c, pos, true)
		if not pos then
			return nil
		end
		pos = pos + 1
	end
	return 4
end

-- rescans the app folders when the last scan is older than five minutes
function M.refresh()
	if os.time() - scannedAt > 300 then
		scan()
	end
end

function M.rows(query)
	local q = query:lower()
	local hits = {}
	for _, app in ipairs(apps) do
		local s = q == "" and 1 or M.score(app.match, q)
		if s then
			hits[#hits + 1] = { app = app, score = s, count = counts[app.path] or 0 }
		end
	end
	table.sort(hits, function(a, b)
		if a.score ~= b.score then
			return a.score < b.score
		end
		if a.count ~= b.count then
			return a.count > b.count
		end
		return a.app.text < b.app.text
	end)
	-- strong = how many rows match by prefix, word or substring (the rest only by letters in order)
	local choices, strong = {}, 0
	for i, hit in ipairs(hits) do
		choices[i] = hit.app
		if hit.score < 4 then
			strong = strong + 1
		end
	end
	return choices, strong
end

function M.open(row)
	counts[row.path] = (counts[row.path] or 0) + 1
	hs.settings.set("launcher.counts", counts)
	hs.application.launchOrFocus(row.path)
end

scan()
return M
