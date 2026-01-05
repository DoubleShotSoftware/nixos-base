-- nixcats/lua/plugins/avante.lua
-- AI code assistant (Claude-based)

local ok, avante = pcall(require, 'avante')
if not ok then
  return
end

avante.setup({
  provider = "claude",
  diff = {
    autojump = true,
    debug = false,
    list_opener = "copen",
  },
  highlights = {
    diff = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
  },
  hints = { enabled = true },
  mappings = {
    diff = {
      both = "cb",
      next = "]x",
      none = "c0",
      ours = "co",
      prev = "[x",
      theirs = "ct",
    },
  },
  windows = {
    sidebar_header = {
      align = "center",
      rounded = true,
    },
    width = 30,
    wrap = true,
  },
})
