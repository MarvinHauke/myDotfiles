-- Launcher source: applications. rows() gives every matching app with its match rank; launcher.lua orders them.
local M = {}

local dirs = {
	"/Applications",
	os.getenv("HOME") .. "/Applications",
	"/System/Applications",
	"/System/Library/CoreServices/Applications",
}
local apps, scannedAt = {}, 0

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
	table.sort(found, function(a, b)
		return a.text:lower() < b.text:lower()
	end)
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

-- rank: 1 = name starts with the text, 2 = a word starts with it or the name contains it,
-- 3 = only the letters in order. Every app for an empty text.
function M.rows(query)
	local q, rows = query:lower(), {}
	for _, app in ipairs(apps) do
		local s = q == "" and 1 or M.score(app.match, q)
		if s then
			app.rank, app.group = s == 1 and 1 or s < 4 and 2 or 3, 1
			rows[#rows + 1] = app
		end
	end
	return rows
end

function M.open(row)
	hs.application.launchOrFocus(row.path)
end

scan()
return M
