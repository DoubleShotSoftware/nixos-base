{
  colorschemes = {
    tokyonight = {
      enable = true;
      settings = {
        day_brightness = 0.3;
        dim_inactive = true;
        hide_inactive_statusline = false;
        light_style = "day";
        lualine_bold = false;
        sidebars = [ "qf" "vista_kind" "terminal" "packer" ];
        on_highlights = ''
          function(hl, colors)
            -- Adjust inactive line number to pop more
            hl.LineNr = {
              fg = colors.orange,
              bold = true,
              bg = colors.bg_dark
            }
            -- Keep cursor line number more prominent
            hl.CursorLineNr = {
              fg = colors.orange,
              bold = true,
              bg = colors.bg_dark
            }
            -- Adjust gutter color manually (without alpha)
            hl.SignColumn = {
              bg = colors.bg_dark, -- Darker gutter background, without alpha
            }
            hl.FoldColumn = {
              bg = colors.bg_dark, -- Matching the gutter color
            }
            hl.LineNrAbove = {
              fg = colors.blue_bright,
              bg = colors.bg_dark, -- Matching the gutter color
            };
            hl.LineNrBelow = {
              fg = colors.blue_bright,
              bg = colors.bg_dark, -- Matching the gutter color
            };
    -- Fix git gutters and diagnostics by setting their background explicitly
    hl.GitSignsAdd = {
      fg = colors.green,
      bg = colors.bg_dark,
    }
    hl.GitSignsChange = {
      fg = colors.blue,
      bg = colors.bg_dark,
    }
    hl.GitSignsDelete = {
      fg = colors.red,
      bg = colors.bg_dark,
    }
    -- Fix LSP lightbulb highlight (if applicable)
    hl.LspDiagnosticsDefaultHint = {
      fg = colors.yellow,
      bg = colors.bg_dark,
    }
    hl.LspDiagnosticsSignHint = {
      fg = colors.yellow,
      bg = colors.bg_dark,
    }
    hl.LspDiagnosticsSignError = {
      fg = colors.red,
      bg = colors.bg_dark,
    }
    hl.LspDiagnosticsSignWarning = {
      fg = colors.yellow,
      bg = colors.bg_dark,
    }
          end
        '';
        style = "night";
        styles = {
          comments = { italic = true; };
          floats = "dark";
          functions = { };
          keywords = { italic = true; };
          sidebars = "dark";
          variables = { };
        };
        terminal_colors = true;
        transparent = true;
      };
    };
  };

}
