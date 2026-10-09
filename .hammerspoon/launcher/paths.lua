-- Launcher source: files and folders.
-- rows() starts with the places (hash -d) and nv aliases (alias x='nvim <path>') from ~/.zshrc.
-- rows(): what was opened here before, recently used folders (zoxide) and files (nvim).
-- search(): the whole file tree below the home folder and on mounted drives (fd lists, fzf ranks).
local M = {}

local score = require("launcher.apps").score

local home = os.getenv("HOME")
local bin = "/opt/homebrew/bin/"
local edit = home .. "/.local/bin/edit" -- opens files and folders in nvim / tmux

local scannedAt = 0
local recentFolders, recentFiles = {}, {} -- rows, most used / most recent first
local maxRecent = 8 -- rows of each kind shown below the apps
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

-- Places and aliases come from zsh itself, so ~/.zshrc stays the only list.
-- The shell is started with a dummy TMUX value: without it ~/.zshrc would attach to the tmux session.
local placeRows = {}
local function scanPlaces()
	local script = [=[for k v in "${(@kv)nameddirs}"; do print -r -- "place	$k	$v"; done
for k v in "${(@kv)aliases}"; do [[ $v == nvim\ * ]] && print -r -- "alias	$k	${(e)v#nvim }"; done]=]
	hs.task
		.new("/usr/bin/env", function(_, out)
			local rows, named = {}, {}
			-- aliases first: a name that is both (notes) behaves like the alias, as in the shell
			for _, wanted in ipairs({ "alias", "place" }) do
				for _, line in ipairs(lines(out)) do
					local kind, name, path = line:match("(%a%a%a%a%a)\t([^\t]+)\t(/.*)$") -- the first line can start with terminal codes
					path = path and path:gsub("/%.$", "")
					local mode = path and hs.fs.attributes(path, "mode")
					if kind == wanted and mode and not named[name] then
						named[name] = true
						local row = pathRow(path, mode == "directory" and "folder" or "file")
						row.text, row.match = name, name:lower() -- only the name is searched
						row.subText = row.subText .. (kind == "alias" and "   (nvim alias)" or "   (place)")
						row.editor = kind == "alias" -- a folder opens in nvim, not as a shell
						row.named = true
						rows[#rows + 1] = row
					end
				end
			end
			table.sort(rows, function(a, b)
				return a.text < b.text
			end)
			placeRows = rows
		end, { "TMUX=launcher", "TERM=screen-256color", "/bin/zsh", "-ic", script })
		:start()
end

-- places and aliases, opened here before, recent folders, recent files; nothing for an empty query.
-- Also returns the set of listed paths, to keep tree rows from repeating them.
function M.rows(query)
	local q, choices, seen = query:lower(), {}, {}
	if q ~= "" then
		pick(placeRows, q, choices, seen)
		pick(historyRows, q, choices, seen)
		pick(recentFolders, q, choices, seen)
		pick(recentFiles, q, choices, seen)
	end
	return choices, seen
end

-- fd writes the tree list once when the launcher opens; fzf then ranks that list on every keystroke.
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
-- ranks the cached path list with fzf and hands up to limit rows to done.
-- wanted() says whether the input is still the one this search was started for.
function M.search(query, limit, wanted, done)
	if searchTimer then
		searchTimer:stop()
	end
	searchTimer = hs.timer.doAfter(0.1, function()
		if searchTask and searchTask:isRunning() then
			searchTask:terminate()
		end
		local cmd = bin .. 'fzf --filter "$1" < "$0" | head -' .. limit
		searchTask = hs.task.new("/bin/sh", function(_, out)
			if not wanted() then
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

function M.cancel()
	if searchTimer then
		searchTimer:stop()
	end
end

-- called each time the launcher opens
function M.refresh()
	if os.time() - scannedAt > 300 then
		scanRecent()
		scanPlaces()
		scannedAt = os.time()
	end
	scanRoots()
	loadHistory()
	listPaths()
end

function M.open(row)
	M.remember(row.file, row.kind)
	hs.task.new(edit, nil, row.editor and { "-e", row.file } or { row.file }):start()
end

function M.reveal(row)
	M.remember(row.file, row.kind)
	hs.task.new("/usr/bin/open", nil, { "-R", row.file }):start()
end

-- input text that searches below a folder row
function M.below(row)
	return "/" .. row.file:gsub("^" .. home .. "/?", "") .. "/"
end

scanRecent()
scanPlaces()
scannedAt = os.time()
loadHistory()
return M
