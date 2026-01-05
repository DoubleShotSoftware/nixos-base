-- nixcats/lua/plugins/zellij-nav.lua
-- Zellij terminal navigator integration

local ok, zellij_nav = pcall(require, 'zellij-nav')
if not ok then
  return
end

zellij_nav.setup()
