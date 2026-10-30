-- Key help, in the style of which-key. Opened by hammerspoon://help?topic=Finder
-- The keys are not listed here: the panel shows the table under the heading "## <topic>"
-- in ~/.config/docs/keys.md (columns Key and Action). Any key or click closes it, except the screenshot keys.
local M = {}

local doc = os.getenv("HOME") .. "/.config/docs/keys.md"
local font, size = "Menlo", 14

-- { { key, action }, ... } from the first table under the heading that starts with topic
function M.rows(topic)
	local rows, inTopic, body = {}, false, false
	for line in io.lines(doc) do
		local heading = line:match("^## (.+)")
		if heading then
			if #rows > 0 then
				break
			end
			inTopic = heading:lower():find(topic:lower(), 1, true) == 1
		elseif inTopic and line:match("^|%s*%-") then
			body = true -- the line under the table header
		elseif inTopic and body and line:match("^|") then
			local cells = {}
			for cell in line:gmatch("|%s*([^|]-)%s*%f[|]") do
				cells[#cells + 1] = cell:gsub("`", "")
			end
			rows[#rows + 1] = { cells[1], cells[2] }
		elseif body then
			break -- end of the table
		end
	end
	return rows
end

local function hide()
	if M.canvas then
		M.canvas:delete()
		M.canvas = nil
	end
	if M.tap then
		M.tap:stop()
	end
	M.shown = nil
end

-- Splits text into lines of at most width characters, at spaces where possible
local function wrap(text, width)
	local lines, line = {}, ""
	for word in text:gmatch("%S+") do
		while utf8.len(word) > width do -- a word longer than a line is cut
			if line ~= "" then
				lines[#lines + 1], line = line, ""
			end
			local cut = utf8.offset(word, width + 1)
			lines[#lines + 1], word = word:sub(1, cut - 1), word:sub(cut)
		end
		if line == "" then
			line = word
		elseif utf8.len(line) + 1 + utf8.len(word) <= width then
			line = line .. " " .. word
		else
			lines[#lines + 1], line = line, word
		end
	end
	lines[#lines + 1] = line
	return lines
end

-- macOS screenshot keys (Cmd+Shift+3/4/5, with or without Ctrl) keep the panel open, so it can be captured
local function isScreenshotKey(event)
	local flags, key = event:getFlags(), event:getKeyCode()
	return flags.cmd and flags.shift
		and (key == hs.keycodes.map["3"] or key == hs.keycodes.map["4"] or key == hs.keycodes.map["5"])
end

-- Shows the panel. sticky: no key closes it, the caller does (M.hide), e.g. the launcher while it is open.
function M.show(topic, sticky)
	hide()
	local rows = M.rows(topic or "")
	if #rows == 0 then
		hs.alert.show("No keys found for " .. tostring(topic))
		return
	end

	local win = hs.window.focusedWindow()
	local screen = (win and win:screen() or hs.screen.mainScreen()):frame()
	local style = { font = { name = font, size = size } }
	local charWidth = hs.drawing.getTextDrawingSize("MMMMMMMMMM", { font = font, size = size }).w / 10
	local lineHeight, pad = size * 1.5, 16
	local columns = #rows > 6 and 2 or 1
	local perColumn = math.ceil(#rows / columns)
	local columnWidth = (screen.w - 2 * pad) / columns
	local maxLines = math.floor(screen.h * 0.6 / lineHeight)

	-- Each column gets its own key width; an action longer than the rest of the line wraps below itself
	local lines, used = {}, 0
	for column = 0, columns - 1 do
		local first, last = column * perColumn + 1, math.min((column + 1) * perColumn, #rows)
		local keyWidth = 0
		for i = first, last do
			keyWidth = math.max(keyWidth, utf8.len(rows[i][1]) or #rows[i][1])
		end
		local actionWidth = math.max(10, math.floor((columnWidth - pad) / charWidth) - keyWidth - 2)
		local line = 0
		for i = first, last do
			for n, part in ipairs(wrap(rows[i][2], actionWidth)) do
				lines[#lines + 1] = { column = column, line = line, key = n == 1 and rows[i][1] or "", keyWidth = keyWidth, text = part }
				line = line + 1
			end
		end
		used = math.max(used, line)
	end
	used = math.min(used, maxLines)

	local height = used * lineHeight + 2 * pad
	local canvas = hs.canvas.new({ x = screen.x, y = screen.y + screen.h - height, w = screen.w, h = height })
	canvas[1] = { type = "rectangle", fillColor = { white = 0.1, alpha = 0.95 } }
	for _, l in ipairs(lines) do
		if l.line < used then
			local gap = string.rep(" ", l.keyWidth - (utf8.len(l.key) or #l.key) + 2)
			local text = hs.styledtext.new(l.key, { font = style.font, color = { hex = "#e0af68" } })
				.. hs.styledtext.new(gap .. l.text, { font = style.font, color = { white = 0.9 } })
			canvas[#canvas + 1] = {
				type = "text",
				text = text,
				frame = { x = pad + l.column * columnWidth, y = pad + l.line * lineHeight, w = columnWidth - pad, h = lineHeight },
			}
		end
	end
	canvas:level(hs.canvas.windowLevels.overlay)
	canvas:show()
	M.canvas, M.shown = canvas, rows

	if sticky then
		return
	end
	-- the key or click that closes the panel still reaches the app
	M.tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.leftMouseDown }, function(event)
		if not isScreenshotKey(event) then
			hide()
		end
		return false
	end)
	M.tap:start()
end

M.hide = hide

-- Opens the panel, or closes it when it is open
function M.toggle(topic)
	if M.canvas then
		hide()
	else
		M.show(topic)
	end
end

return M
