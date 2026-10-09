-- App launcher and calculator. Opened by hammerspoon://launcher
-- Below the apps it lists what was opened here before, recently used folders (zoxide) and files (nvim),
-- then matches from the whole file tree. A leading "/" searches the tree only. See ~/.config/docs/launcher.md
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
local recentFolders, recentFiles = {}, {} -- rows, most used / most recent first
local maxRecent = 8 -- rows of each kind shown below the apps
local maxTree = 10 -- rows from the file tree at the end of the plain list
local roots = { home } -- where the tree search looks: the home folder and mounted drives
-- files and folders opened through the launcher, newest first: { { path = ..., kind = ... }, ... }
local history = hs.settings.get("launcher.history") or {}
local historyRows = {}

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
	recentFiles, recentFolders = {}, {}
	for _, path in ipairs(lines(files)) do
		if path:sub(1, 1) == "/" and hs.fs.attributes(path, "mode") == "file" then
			recentFiles[#recentFiles + 1] = pathRow(path, "file")
		end
	end
	for _, path in ipairs(lines(folders)) do
		recentFolders[#recentFolders + 1] = pathRow(path, "folder")
	end
end

-- external drives; /Volumes also holds a link back to the system disk, which is skipped
local function scanRoots()
	roots = { home }
	for entry in hs.fs.dir("/Volumes") do
		local path = "/Volumes/" .. entry
		if entry:sub(1, 1) ~= "." and hs.fs.symlinkAttributes(path, "mode") == "directory" then
			roots[#roots + 1] = path
		end
	end
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

-- rows for the history entries that still exist (a drive that is not plugged in hides its entries)
local function loadHistory()
	historyRows = {}
	for _, entry in ipairs(history) do
		if hs.fs.attributes(entry.path, "mode") then
			historyRows[#historyRows + 1] = pathRow(entry.path, entry.kind)
		end
	end
end

function M.remember(path, kind)
	for i, entry in ipairs(history) do
		if entry.path == path then
			table.remove(history, i)
			break
		end
	end
	table.insert(history, 1, { path = path, kind = kind })
	while #history > 200 do
		table.remove(history)
	end
	hs.settings.set("launcher.history", history)
	loadHistory()
end

-- best rows of one list: name starts with q, then name contains q, then only the path does.
-- seen holds the paths that are already listed.
local function pick(rows, q, into, seen)
	local ranked = { {}, {}, {} }
	for _, row in ipairs(rows) do
		local s = score(row.text:lower(), q)
		local rank = s == 1 and 1 or (s and s < 4) and 2 or row.match:find(q, 1, true) and 3
		if rank and not seen[row.file] then
			seen[row.file] = true
			table.insert(ranked[rank], row)
		end
	end
	local shown = 0
	for _, group in ipairs(ranked) do
		for _, row in ipairs(group) do
			if shown >= maxRecent then
				return
			end
			into[#into + 1] = row
			shown = shown + 1
		end
	end
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
	-- after the apps: opened here before, recent folders, recent files; only once something is typed
	local seen = {}
	if q ~= "" then
		pick(historyRows, q, choices, seen)
		pick(recentFolders, q, choices, seen)
		pick(recentFiles, q, choices, seen)
	end
	return choices, seen
end

-- "/text": every file and folder below the home folder and on mounted drives.
-- fd writes the list once when the launcher opens; fzf then ranks that list on every keystroke.
local pathList = home .. "/.cache/launcher-paths"
local listTask
local function listPaths()
	if listTask and listTask:isRunning() then
		return
	end
	-- the home prefix is cut off so that home rows read like in the shell
	local cmd = bin .. "fd . \"$@\" --max-depth 7 -E Library -E node_modules -E '*.app' 2>/dev/null"
		.. ' | sed "s|^$HOME/||" > "$0.new" && mv "$0.new" "$0"'
	listTask = hs.task.new("/bin/sh", nil, { "-c", cmd, pathList, table.unpack(roots) })
	listTask:start()
end

local searchTask, searchTimer
local chooser
-- ranks the cached path list with fzf and hands up to limit rows to done, unless the input changed meanwhile
local function search(query, limit, input, done)
	if searchTimer then
		searchTimer:stop()
	end
	searchTimer = hs.timer.doAfter(0.1, function()
		if searchTask and searchTask:isRunning() then
			searchTask:terminate()
		end
		local cmd = bin .. 'fzf --filter "$1" < "$0" | head -' .. limit
		searchTask = hs.task.new("/bin/sh", function(_, out)
			if chooser:query() ~= input then
				return -- typed on in the meantime
			end
			local rows = {}
			for _, found in ipairs(lines(out)) do
				local folder = found:sub(-1) == "/"
				local path = found:gsub("/$", "")
				if path:sub(1, 1) ~= "/" then
					path = home .. "/" .. path
				end
				rows[#rows + 1] = pathRow(path, folder and "folder" or "file")
			end
			done(rows)
		end, { "-c", cmd, pathList, query })
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
		M.remember(choice.file, choice.kind)
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
			search(query:sub(2), 40, query, function(rows)
				chooser:choices(rows)
			end)
		else
			chooser:choices({})
		end
	else
		local choices, seen = filter(query)
		chooser:choices(choices)
		-- from 3 characters on, matches from the whole file tree follow at the end
		if #query >= 3 then
			search(query, maxTree + #choices, query, function(rows)
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
		elseif searchTimer then
			searchTimer:stop()
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
			M.remember(row.file, row.kind)
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
	scanRoots()
	loadHistory()
	listPaths()
	chooser:query(query or "")
	update(query or "")
	chooser:show()
end

scan()
scanRecent()
loadHistory()
return M
