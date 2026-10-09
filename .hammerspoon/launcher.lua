-- App launcher and calculator. Opened by hammerspoon://launcher
-- Below the apps it lists recently used files (nvim) and folders (zoxide); a leading "/" searches
-- all files and folders below the home folder. See ~/.config/docs/launcher.md
local M = {}

local home = os.getenv("HOME")
local bin = "/opt/homebrew/bin/"
local edit = home .. "/.local/bin/edit" -- opens files and folders in nvim / tmux

local dirs = {
	"/Applications",
	home .. "/Applications",
	"/System/Applications",
	"/System/Library/CoreServices/Applications",
}
local apps, scannedAt = {}, 0
local counts = hs.settings.get("launcher.counts") or {}
local recent = {} -- file and folder rows, most recently used first
local maxRecent = 12 -- rows shown below the apps

-- row for a file or folder; folders are given with a trailing slash or as kind
local function pathRow(path, kind)
	local short = path:gsub("^" .. home, "~")
	return {
		text = path:match("([^/]+)/?$") or path,
		subText = short,
		file = path,
		kind = kind,
		match = short:lower(),
		image = kind == "folder" and hs.image.iconForFileType("public.folder")
			or hs.image.iconForFileType(path:match("%.(%w+)$") or "public.text"),
	}
end

local function lines(text)
	local out = {}
	for line in (text or ""):gmatch("[^\r\n]+") do
		out[#out + 1] = line
	end
	return out
end

-- nvim's own list of recent files, then zoxide's list of folders
local function scanRecent()
	local files = hs.execute(bin .. "nvim --headless -u NONE -c 'for f in v:oldfiles | echo f | endfor' -c qa 2>&1")
	local folders = hs.execute(bin .. "zoxide query -l 2>/dev/null")
	local found = {}
	for _, path in ipairs(lines(files)) do
		if path:sub(1, 1) == "/" and hs.fs.attributes(path, "mode") == "file" then
			found[#found + 1] = pathRow(path, "file")
		end
	end
	for _, path in ipairs(lines(folders)) do
		found[#found + 1] = pathRow(path, "folder")
	end
	recent = found
end

local function scan()
	local found, seen = {}, {}
	local function add(path)
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
			match = (shown .. " " .. file):lower(),
			image = hs.image.iconForFile(path),
		}
	end
	local function walk(dir, depth)
		local ok, iter, state = pcall(hs.fs.dir, dir)
		if not ok then
			return
		end
		for entry in iter, state do
			local path = dir .. "/" .. entry
			if entry:sub(1, 1) == "." then
				-- skip
			elseif entry:sub(-4) == ".app" then
				add(path)
			elseif depth > 0 and hs.fs.attributes(path, "mode") == "directory" then
				walk(path, depth - 1)
			end
		end
	end
	for _, dir in ipairs(dirs) do
		walk(dir, 1)
	end
	add("/System/Library/CoreServices/Finder.app")
	apps, scannedAt = found, os.time()
end

-- 1 = prefix, 2 = word prefix, 3 = substring, 4 = letters in order, nil = no match
local function score(name, q)
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

local function filter(query)
	local q = query:lower()
	local hits = {}
	for _, app in ipairs(apps) do
		local s = q == "" and 1 or score(app.match, q)
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
	local choices = {}
	for i, hit in ipairs(hits) do
		choices[i] = hit.app
	end
	-- recent files and folders after the apps, only once something is typed
	if q ~= "" then
		local shown = 0
		for _, row in ipairs(recent) do
			if shown >= maxRecent then
				break
			end
			-- no letters-in-order matching here, it is too noisy on paths
			if (score(row.text:lower(), q) or 4) < 4 or row.match:find(q, 1, true) then
				choices[#choices + 1] = row
				shown = shown + 1
			end
		end
	end
	return choices
end

-- "/text": every file and folder below the home folder, listed by fd and ranked by fzf
local searchTask, searchTimer
local chooser
local function search(query)
	if searchTimer then
		searchTimer:stop()
	end
	searchTimer = hs.timer.doAfter(0.15, function()
		if searchTask and searchTask:isRunning() then
			searchTask:terminate()
		end
		local cmd = bin .. "fd . --base-directory \"$HOME\" --max-depth 7 -E Library -E node_modules -E '*.app'"
			.. " | " .. bin .. 'fzf --filter "$1" | head -40'
		searchTask = hs.task.new("/bin/sh", function(_, out)
			if chooser:query() ~= "/" .. query then
				return -- typed on in the meantime
			end
			local rows = {}
			for _, rel in ipairs(lines(out)) do
				local folder = rel:sub(-1) == "/"
				rows[#rows + 1] = pathRow(home .. "/" .. rel:gsub("/$", ""), folder and "folder" or "file")
			end
			chooser:choices(rows)
		end, { "-c", cmd, "sh", query })
		searchTask:start()
	end)
end

local function reveal(path)
	hs.task.new("/usr/bin/open", nil, { "-R", path }):start()
end

local calcEnv = { pi = math.pi, ln = math.log }
for _, name in ipairs({ "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "log", "exp", "abs", "floor", "ceil", "min", "max" }) do
	calcEnv[name] = math[name]
end

-- "= 2*pi*10e3" -> one row with the result, Enter copies it
local function calculate(expr)
	local fn = load("return " .. expr, "calc", "t", calcEnv)
	local ok, result = pcall(fn or error)
	if not ok or type(result) ~= "number" then
		return {}
	end
	local text = result == math.floor(result) and string.format("%d", result) or string.format("%.10g", result)
	return { { text = text, subText = "Enter copies the result", calc = true } }
end

chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	if choice.calc then
		hs.pasteboard.setContents(choice.text)
		return
	end
	if choice.file then
		hs.task.new(edit, nil, { choice.file }):start()
		return
	end
	counts[choice.path] = (counts[choice.path] or 0) + 1
	hs.settings.set("launcher.counts", counts)
	hs.application.launchOrFocus(choice.path)
end)

local function update(query)
	if query:sub(1, 1) == "=" then
		chooser:choices(calculate(query:sub(2)))
	elseif query:sub(1, 1) == "/" then
		if #query > 1 then
			search(query:sub(2))
		else
			chooser:choices({})
		end
	else
		chooser:choices(filter(query))
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
			reveal(row.file)
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
		local below = "/" .. row.file:gsub("^" .. home .. "/?", "") .. "/"
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
	if os.time() - scannedAt > 300 then
		scan()
		scanRecent()
	end
	chooser:query(query or "")
	update(query or "")
	chooser:show()
end

scan()
scanRecent()
return M
