-- OS-wide clipboard history (text only). Opened by hammerspoon://clipboard
local M = {}

local file = os.getenv("HOME") .. "/.local/state/clipboard.json"
local limit = 100
-- password managers mark secrets with these types (nspasteboard.org)
local skip = { ["org.nspasteboard.ConcealedType"] = true, ["org.nspasteboard.TransientType"] = true }

local history = hs.fs.attributes(file) and hs.json.read(file) or {}

local function save()
	local created = not hs.fs.attributes(file)
	hs.json.write(history, file, false, true)
	if created then
		hs.execute("chmod 600 '" .. file .. "'")
	end
end

local function add(text)
	if not text or text:match("^%s*$") then
		return
	end
	for _, uti in ipairs(hs.pasteboard.contentTypes() or {}) do
		if skip[uti] then
			return
		end
	end
	for i, old in ipairs(history) do
		if old == text then
			table.remove(history, i)
			break
		end
	end
	table.insert(history, 1, text)
	while #history > limit do
		table.remove(history)
	end
	save()
end

local chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	hs.pasteboard.setContents(history[choice.index])
	hs.timer.doAfter(0.1, function()
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end)
end)

local function choices()
	local rows = {}
	for i, text in ipairs(history) do
		local _, breaks = text:gsub("\n", "\n")
		rows[i] = {
			text = (text:match("[^\n]*%S[^\n]*") or ""):gsub("^%s+", ""):sub(1, 120),
			subText = breaks > 0 and (breaks + 1) .. " lines" or nil,
			index = i,
		}
	end
	return rows
end

function M.toggle()
	if chooser:isVisible() then
		chooser:hide()
		return
	end
	chooser:query("")
	chooser:choices(choices())
	chooser:show()
end

M.watcher = hs.pasteboard.watcher.new(add)

return M
