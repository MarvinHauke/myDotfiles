-- OS-wide clipboard history. Opened by hammerspoon://clipboard
-- Entries are copied text, or { image = path } for screenshots (added by capture.lua).
local M = {}

local file = os.getenv("HOME") .. "/.local/state/clipboard.json"
local limit = 100
-- Secrets stay out of the history. They can still be pasted normally with Cmd+V.
-- 1. anything copied while one of these apps is in front
local secretApps = {
	["com.apple.Passwords"] = true,
	["com.apple.keychainaccess"] = true,
	["org.keepassxc.keepassxc"] = true,
}
-- 2. anything a password manager marks as secret (nspasteboard.org types and similar)
local secretTypes = { "concealed", "transient", "sensitive", "password" }

local function isSecret()
	local front = hs.application.frontmostApplication()
	if front and secretApps[front:bundleID()] then
		return true
	end
	for _, uti in ipairs(hs.pasteboard.contentTypes() or {}) do
		for _, word in ipairs(secretTypes) do
			if uti:lower():find(word, 1, true) then
				return true
			end
		end
	end
	return false
end

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
	if isSecret() then
		return
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

-- Offer an image file in the history without touching the clipboard itself.
function M.addImage(path)
	for i, old in ipairs(history) do
		if type(old) == "table" and old.image == path then
			table.remove(history, i)
			break
		end
	end
	table.insert(history, 1, { image = path })
	save()
end

local chooser = hs.chooser.new(function(choice)
	if not choice then
		return
	end
	local entry = history[choice.index]
	if type(entry) == "table" then
		local image = hs.image.imageFromPath(entry.image)
		if not image then
			return
		end
		hs.pasteboard.writeObjects(image)
	else
		hs.pasteboard.setContents(entry)
	end
	hs.timer.doAfter(0.1, function()
		hs.eventtap.keyStroke({ "cmd" }, "v")
	end)
end)

local choices

-- right-click a row to delete it from the history
chooser:rightClickCallback(function(row)
	local choice = chooser:selectedRowContents(row)
	if choice and choice.index then
		table.remove(history, choice.index)
		save()
		chooser:choices(choices())
	end
end)

function choices()
	local rows = {}
	for i, entry in ipairs(history) do
		if type(entry) == "table" then
			-- image files in /tmp/shots disappear after a while; then the row is left out
			local image = hs.image.imageFromPath(entry.image)
			if image then
				rows[#rows + 1] = { text = "Image " .. entry.image:match("[^/]+$"), subText = "pastes the picture", image = image, index = i }
			end
		else
			local _, breaks = entry:gsub("\n", "\n")
			rows[#rows + 1] = {
				text = (entry:match("[^\n]*%S[^\n]*") or ""):gsub("^%s+", ""):sub(1, 120),
				subText = breaks > 0 and (breaks + 1) .. " lines" or nil,
				index = i,
			}
		end
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
