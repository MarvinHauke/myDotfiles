-- Launcher source: calculator. "= 2*pi*10e3" gives one row with the result, Enter copies it.
-- Plain input that looks like math ("2*pi*10e3") calculates too, see looksLikeMath.
-- Results that are probably not what was meant get the warning icon and the reason as subtext.
-- Sub-calculators (electronics etc.) belong here.
local M = {}

local icons = hs.configdir .. "/launcher/icons/"
local calcIcon = hs.image.imageFromPath(icons .. "calc.png")
local warnIcon = hs.image.imageFromPath(icons .. "warn.png")

local calcEnv = { pi = math.pi, ln = math.log }
for _, name in ipairs({ "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "log", "exp", "abs", "floor", "ceil", "min", "max" }) do
	calcEnv[name] = math[name]
end

-- the number, if expr gives exactly one; "2,5*3" gives two (2 and 15)
local function eval(expr)
	local fn = load("return " .. expr, "calc", "t", calcEnv)
	if not fn then
		return nil
	end
	local out = table.pack(pcall(fn))
	if out[1] and out.n == 2 and type(out[2]) == "number" then
		return out[2]
	end
end

local function format(result)
	if result == math.floor(result) and math.abs(result) < 2 ^ 53 then
		return string.format("%d", result)
	end
	return string.format("%.10g", result)
end

-- a digit and an operator or bracket: "2*pi", "sqrt(2)", "2,5*3"; not "pi", "2024", "mp3"
function M.looksLikeMath(text)
	return text:find("%d") ~= nil and text:find("[%+%-%*/%^%%%(,]") ~= nil
end

function M.rows(expr)
	local warnings = {}
	local result = eval(expr)
	if not result then
		-- German decimal comma: "2,5*3" read as 2.5*3
		local dotted = expr:gsub("(%d),(%d)", "%1.%2")
		result = dotted ~= expr and eval(dotted)
		if not result then
			return {}
		end
		warnings[#warnings + 1] = "comma read as decimal point"
	end
	if expr:find("%", 1, true) then
		warnings[#warnings + 1] = "% is modulo, not percent"
	end
	local trig = { sin = true, cos = true, tan = true }
	for name, arg in expr:gmatch("%f[%a](%a+)%(%s*([%d%.]+)") do
		if trig[name] and (tonumber(arg) or 0) > 2 * math.pi then
			warnings[#warnings + 1] = "sin/cos/tan take radians"
			break
		end
	end
	if result ~= result or math.abs(result) == math.huge then
		warnings[#warnings + 1] = "division by zero or undefined"
	elseif math.abs(result) >= 2 ^ 53 then
		warnings[#warnings + 1] = "beyond the exact integer range"
	end
	local warn = #warnings > 0
	return {
		{
			text = format(result),
			subText = warn and ("⚠ " .. table.concat(warnings, ", ") .. " · Enter copies")
				or ("= " .. expr .. " · Enter copies"),
			image = warn and warnIcon or calcIcon,
			calc = true,
			warn = warn,
		},
	}
end

function M.open(row)
	hs.pasteboard.setContents(row.text)
end

return M
