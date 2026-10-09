-- Key help, in the style of which-key. Opened by hammerspoon://help?topic=Finder
-- The keys are not listed here: the panel shows the table under the heading "## <topic>"
-- in ~/.config/docs/keys.md (columns Key and Action). Any key or click closes it.
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

function M.toggle(topic)
	if M.canvas then
		hide()
		return
	end
	local rows = M.rows(topic or "")
	if #rows == 0 then
		hs.alert.show("No keys found for " .. tostring(topic))
		return
	end
	local keyWidth = 0
	for _, row in ipairs(rows) do
		keyWidth = math.max(keyWidth, utf8.len(row[1]) or #row[1])
	end

	local win = hs.window.focusedWindow()
	local screen = (win and win:screen() or hs.screen.mainScreen()):frame()
	local columns = #rows > 6 and 2 or 1
	local perColumn = math.ceil(#rows / columns)
	local lineHeight, pad = size * 1.5, 16
	local height = perColumn * lineHeight + 2 * pad
	local columnWidth = (screen.w - 2 * pad) / columns

	local canvas = hs.canvas.new({ x = screen.x, y = screen.y + screen.h - height, w = screen.w, h = height })
	canvas[1] = { type = "rectangle", fillColor = { white = 0.1, alpha = 0.95 } }
	for i, row in ipairs(rows) do
		local column, line = math.floor((i - 1) / perColumn), (i - 1) % perColumn
		local gap = string.rep(" ", keyWidth - (utf8.len(row[1]) or #row[1]) + 2)
		local text = hs.styledtext.new(row[1], { font = { name = font, size = size }, color = { hex = "#e0af68" } })
			.. hs.styledtext.new(gap .. row[2], { font = { name = font, size = size }, color = { white = 0.9 } })
		canvas[#canvas + 1] = {
			type = "text",
			text = text,
			frame = { x = pad + column * columnWidth, y = pad + line * lineHeight, w = columnWidth - pad, h = lineHeight },
		}
	end
	canvas:level(hs.canvas.windowLevels.overlay)
	canvas:show()
	M.canvas, M.shown = canvas, rows

	-- the key or click that closes the panel still reaches the app
	M.tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.leftMouseDown }, function()
		hide()
		return false
	end)
	M.tap:start()
end

return M
