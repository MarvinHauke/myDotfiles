-- Ghost text: the calculator result in grey right after the typed text in the launcher's input.
-- hs.chooser has no API for its input field, so the field is looked up in the accessibility
-- tree of the chooser window, which also gives the box of the typed text (AXBoundsForRange).
-- The ghost text goes right after that box, in a font as high as the box.
-- If the position is off, tune these:
local fontSize = 20 -- only used when the box of the typed text is not available
local gap = 6 -- space between the typed text and the ghost text
local M = {}

local font = { name = ".AppleSystemUIFont", size = fontSize }
local canvas = hs.canvas.new({ x = 0, y = 0, w = 10, h = 10 })
canvas:level(hs.canvas.windowLevels.popUpMenu)
canvas[1] = {
	type = "text",
	text = "",
	textFont = font.name,
	textSize = fontSize,
	textColor = { white = 0.5, alpha = 0.9 },
}
local field -- the input field's accessibility element, looked up once per opening

local function findField(element, depth)
	if element:attributeValue("AXRole") == "AXTextField" then
		return element
	end
	if depth > 0 then
		for _, child in ipairs(element:attributeValue("AXChildren") or {}) do
			local found = findField(child, depth - 1)
			if found then
				return found
			end
		end
	end
end

local function lookUp()
	local app = hs.application.get("org.hammerspoon.Hammerspoon")
	for _, win in ipairs(app and app:allWindows() or {}) do
		if win:title() ~= "Hammerspoon Console" then
			local element = findField(hs.axuielement.windowElement(win), 4)
			if element then
				return element
			end
		end
	end
end

-- query: the whole input; text: the ghost text, nil hides it
function M.show(query, text)
	if not text then
		canvas:hide()
		return
	end
	field = field or lookUp()
	if not field then
		return
	end
	local pos, size = field:attributeValue("AXPosition"), field:attributeValue("AXSize")
	if not pos or not size then
		return
	end
	local box = field:parameterizedAttributeValue("AXBoundsForRange", { location = 0, length = utf8.len(query) or #query })
	local textFont = { name = font.name, size = box and box.h > 0 and box.h / 1.2 or fontSize }
	local ghostSize = hs.drawing.getTextDrawingSize(text, textFont)
	local x, y
	if box and box.w > 0 then
		x, y = box.x + box.w + gap, box.y + (box.h - ghostSize.h) / 2
	else
		x = pos.x + hs.drawing.getTextDrawingSize(query, textFont).w + gap
		y = pos.y + (size.h - ghostSize.h) / 2
	end
	if x + ghostSize.w > pos.x + size.w then
		canvas:hide()
		return
	end
	canvas:frame({ x = x, y = y, w = ghostSize.w + 4, h = ghostSize.h })
	canvas[1].text = text
	canvas[1].textSize = textFont.size
	canvas:show()
end

function M.hide()
	canvas:hide()
	field = nil
end

return M
