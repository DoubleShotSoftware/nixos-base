local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

-- Function to create an input popup
local function tab_rename_popup()
    -- Create the input popup
    local input = Input({
        position = "50%",
        size = {width = 40},
        border = {
            style = "rounded",
            text = {top = " Rename Tab ", top_align = "center"}
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
        }
    }, {
        prompt = "> ",
        default_value = "",
        on_submit = function(value)
            -- Execute the Tab Rename command with the input value
            vim.cmd("TabRename " .. vim.fn.fnameescape(value))
        end
    })

    -- Mount the input popup
    input:mount()

    -- Close the popup on focus lost
    input:on(event.BufLeave, function() input:unmount() end)
end

-- Create a user command to trigger the tab rename popup
vim.api.nvim_create_user_command("TabRenamePopup",
                                 function() tab_rename_popup() end, {})

local theme = {
    fill = "TabLineFill",
    head = {fg = "#8aadf4", bg = "#24273a", style = "italic"},
    current_tab = {fg = "#1e2030", bg = "#8aadf4", style = "italic"},
    tab = {fg = "#8aadf4", bg = "#24273a", style = "italic"},
    win = {fg = "#1e2030", bg = "#8aadf4", style = "italic"},
    tail = {fg = "#8aadf4", bg = "#24273a", style = "italic"}
}

require("tabby.tabline").set(function(line)
    return {
        {
            {"  ", hl = theme.head}, line.sep("", theme.head, theme.fill) -- 
        },
        line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
                line.sep("", hl, theme.fill), -- 
                tab.is_current() and "" or "",
                tab.number(),
                tab.name(),
                -- tab.close_btn(''), -- show a close button
                line.sep("", hl, theme.fill), -- 
                hl = hl,
                margin = " "
            }
        end),

        line.spacer(),
        -- shows list of windows in tab
        -- line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
        --  return {
        --    line.sep('', theme.win, theme.fill),
        --    win.is_current() and '' or '',
        --    win.buf_name(),
        --    line.sep('', theme.win, theme.fill),
        --    hl = theme.win,
        --    margin = ' ',
        --  }
        -- end),
        {
            line.sep("", theme.tail, theme.fill), -- 
            {"  ", hl = theme.tail}
        },
        hl = theme.fill
    }
end)
