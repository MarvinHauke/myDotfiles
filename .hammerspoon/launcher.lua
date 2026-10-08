-- App launcher and calculator. Opened by hammerspoon://launcher
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
	return choices
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

local chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	if choice.calc then
		hs.pasteboard.setContents(choice.text)
		return
	end
	counts[choice.path] = (counts[choice.path] or 0) + 1
	hs.settings.set("launcher.counts", counts)
	hs.application.launchOrFocus(choice.path)
end)

chooser:queryChangedCallback(function(query)
	if query:sub(1, 1) == "=" then
		chooser:choices(calculate(query:sub(2)))
	else
		chooser:choices(filter(query))
	end
end)

-- Tab writes the highlighted app name into the input. Only listens while the launcher is open.
local tabTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	if event:getKeyCode() ~= hs.keycodes.map.tab or next(event:getFlags()) then
		return false
	end
	local row = chooser:selectedRowContents()
	if row and row.path then
		chooser:query(row.text)
		chooser:choices(filter(row.text))
	end
	return true
end)
chooser:showCallback(function()
	tabTap:start()
end)
chooser:hideCallback(function()
	tabTap:stop()
end)

function M.toggle()
	if chooser:isVisible() then
		chooser:hide()
		return
	end
	if os.time() - scannedAt > 300 then
		scan()
	end
	chooser:query("")
	chooser:choices(filter(""))
	chooser:show()
end

scan()
return M
