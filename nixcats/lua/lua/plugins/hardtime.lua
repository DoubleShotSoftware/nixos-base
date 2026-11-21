local ok, hardtime = pcall(require, "hardtime")
if not ok then
  return
end

hardtime.setup({
  disable_mouse = false,
  disabled_filetypes = {
    lazygit = true,
    codediff = true,
    ["Diffview.*"] = true,
  },
})
