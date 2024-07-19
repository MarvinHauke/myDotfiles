local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local r = require("luasnip.extras").rep
local f = ls.function_node

local function date()
  return os.date("%d-%m-%y")
end


ls.add_snippets("norg", {
  s("header", {
    t({ "*" }), i(1), t({ "", "" }),             --Title placeholder
    t({ "Date: " }), f(date, {}), t({ "", "" }), --Date placeholder
  }),
})
