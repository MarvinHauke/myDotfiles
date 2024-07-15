local ls = require("plugins/luasnip")
local s = ls.snippet
local f = ls.function_node


local function date()
  return os.date("%Y-%m-%d")
end

ls.add_snippets("all", {
  s("date", {
    f(date, {}), -- "date" is the trigger for the snippet
  }),
})
