-- Launcher source: calculator. "= 2*pi*10e3" gives one row with the result, Enter copies it.
-- Sub-calculators (electronics etc.) belong here.
local M = {}

local calcEnv = { pi = math.pi, ln = math.log }
for _, name in ipairs({ "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "log", "exp", "abs", "floor", "ceil", "min", "max" }) do
	calcEnv[name] = math[name]
end

function M.rows(expr)
	local fn = load("return " .. expr, "calc", "t", calcEnv)
	local ok, result = pcall(fn or error)
	if not ok or type(result) ~= "number" then
		return {}
	end
	local text = result == math.floor(result) and string.format("%d", result) or string.format("%.10g", result)
	return { { text = text, subText = "Enter copies the result", calc = true } }
end

function M.open(row)
	hs.pasteboard.setContents(row.text)
end

return M
