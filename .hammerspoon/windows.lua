-- Window placement. Called by hammerspoon://win?pos=<name>
local M = {}

hs.window.animationDuration = 0

local units = {
	left = { 0, 0, 0.5, 1 },
	right = { 0.5, 0, 0.5, 1 },
	top = { 0, 0, 1, 0.5 },
	bottom = { 0, 0.5, 1, 0.5 },
	topleft = { 0, 0, 0.5, 0.5 },
	topright = { 0.5, 0, 0.5, 0.5 },
	bottomleft = { 0, 0.5, 0.5, 0.5 },
	bottomright = { 0.5, 0.5, 0.5, 0.5 },
}
-- maximized > centered 2/3 > centered 1/2
local sizes = { { 0, 0, 1, 1 }, { 1 / 6, 0, 2 / 3, 1 }, { 0.25, 0, 0.5, 1 } }

local cycled = {} -- window id -> { index, frame }
local focused = {} -- window id -> { orig, max }

local function same(a, b)
	return math.abs(a.x - b.x) < 2 and math.abs(a.y - b.y) < 2 and math.abs(a.w - b.w) < 2 and math.abs(a.h - b.h) < 2
end

local function cycle(win)
	local id = win:id()
	local last = cycled[id]
	local index = (last and same(win:frame(), last.frame)) and last.index % #sizes + 1 or 1
	win:moveToUnit(sizes[index])
	cycled[id] = { index = index, frame = win:frame() }
end

-- maximize, or put back where it was
local function focus(win)
	local id = win:id()
	local last = focused[id]
	if last and same(win:frame(), last.max) then
		win:setFrame(last.orig)
		focused[id] = nil
	else
		local orig = win:frame()
		win:maximize()
		focused[id] = { orig = orig, max = win:frame() }
	end
end

function M.place(pos)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	if pos == "cycle" then
		cycle(win)
	elseif pos == "focus" then
		focus(win)
	elseif pos == "screen" then
		win:moveToScreen(win:screen():next(), false, true)
	elseif units[pos] then
		win:moveToUnit(units[pos])
	end
end

return M
