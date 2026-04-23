local nixCats = require('nixCats')

if not nixCats.cats["languages.kotlin"] then
  return
end

vim.filetype.add({
  extension = {
    kt = 'kotlin',
    kts = 'kotlin',
  },
  pattern = {
    ['.*/build%.gradle%.kts'] = 'kotlin',
    ['.*/settings%.gradle%.kts'] = 'kotlin',
  },
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('KotlinLanguageSetup', { clear = true }),
  pattern = 'kotlin',
  callback = function(ev)
    local opts = {
      shiftwidth = 4,
      softtabstop = 4,
      tabstop = 4,
      expandtab = true,
    }

    for key, value in pairs(opts) do
      vim.bo[ev.buf][key] = value
    end
  end,
})
