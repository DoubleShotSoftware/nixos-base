{ ... }: {
  diagnostic.settings = {

    virtual_lines = { current_line = true; };
  };
  opts = {
    # allows neovim to access the system clipboard
    # Every wrapped line will continue visually indented
    breakindent = true;
    # more space in the neovim command line for displaying messages
    cmdheight = 2;
    # so that `` is visible in markdown files
    conceallevel = 0;
    # the encoding written to a file
    fileencoding = "utf-8";
    # ignore case in search patterns
    ignorecase = true;
    # allow the mouse to be used in neovim
    mouse = "a";
    # pop up menu height
    pumheight = 10;
    # we don't need to see things like # INSERT # anymore
    showmode = false;
    # always show tabs
    showtabline = 2;

    # smart case
    smartcase = true;
    # make indenting smarter again
    smartindent = true;
    # force all horizontal splits to go below current window
    splitbelow = true;
    # force all vertical splits to go to the right of current window
    splitright = true;
    # set term gui colors (most terminals support this)
    termguicolors = true;
    # time to wait for a mapped sequence to complete (in milliseconds)
    timeoutlen = 1000;
    # faster completion (4000ms default)
    # if a file is being edited by another program (or was written to file while editing with another program) it is not allowed to be edited
    writebackup = false;
    # convert tabs to spaces
    # the number of spaces inserted for each indentation
    # highlight the current line
    cursorline = true;
    cursorlineopt = "number";
    # set numbered lines
    number = true;
    # set relative numbered lines
    relativenumber = true;
    # set number column width to 2 {default 4}
    numberwidth = 2;
    # always show the sign column otherwise it would shift the text each time
    # display lines as one long line
    wrap = false;
    # is one of my fav
    scrolloff = 8;
    sidescrolloff = 8;
    # the font used in graphical neovim applications
    laststatus = 3;
    # insert 2 spaces for a tab
    tabstop = 2;
    softtabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    # highlight all matches on previous search pattern
    hlsearch = false;
    incsearch = true;
    signcolumn = "yes";
    # https://youtu.be/w7i4amO_zaE?si=dYxa4AR4jrZAqG0S&t=1458
    updatetime = 50;
    colorcolumn = "120";
    # folding powered by treesitter
    # https://github.com/nvim-treesitter/nvim-treesitter#folding
    # look for foldenable: https://github.com/neovim/neovim/blob/master/src/nvim/options.lua
    # Vim cheatsheet, look for folds keys: https://devhints.io/vim
    # default is "normal"
    foldmethod = "expr";
    foldenable = true;
    foldlevel = 8;
  };

}
