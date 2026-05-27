local ok, precognition = pcall(require, "precognition")
if not ok then
  return
end

precognition.setup({
  startVisible = true,
  showBlankVirtLine = true,
  highlightFullVirtLine = false,
  highlightColor = { link = "Comment" },
  targetedMotionHighlightColor = { link = "PrecognitionTargetedMotionDefault" },
  textObjectHighlightColors = {
    { link = "DiffText" },
    { link = "DiffChange" },
    { link = "Visual" },
  },
  targetedMotionHints = {
    enabled = true,
    prio = 1,
  },
  gutterHints = {
    G = { text = "G", prio = 10 },
    gg = { text = "gg", prio = 9 },
    PrevParagraph = { text = "{", prio = 8 },
    NextParagraph = { text = "}", prio = 8 },
  },
  disabled_fts = {
    "neo-tree",
    "TelescopePrompt",
    "lazygit",
    "trouble",
    "noice",
    "snacks_dashboard",
    "lspsaga",
    "help",
    "qf",
  },
})
