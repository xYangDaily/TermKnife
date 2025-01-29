local histobj = vim.fn.stdpath('config') .. '/plugged/hist-obj/autoload/histobj.vim'
if vim.fn.isdirectory(vim.fn.fnamemodify(histobj, ":p:h")) == 1 then
    vim.cmd("source " .. histobj)
end

local histobjsearch = vim.fn.stdpath('config') .. '/plugged/hist-obj/autoload/histobjsearch.vim'
if vim.fn.isdirectory(vim.fn.fnamemodify(histobjsearch, ":p:h")) == 1 then
    vim.cmd("source " .. histobjsearch)
end

vim.cmd [[
call plug#begin()
Plug 'easymotion/vim-easymotion', {'frozen': 1}
Plug 'karb94/neoscroll.nvim', {'frozen': 1}
Plug 'luochen1990/select-and-search', {'frozen': 1}
Plug 'junegunn/vim-peekaboo', {'frozen': 1}

Plug 'christoomey/vim-tmux-navigator', {'frozen': 1}
Plug 'roxma/vim-tmux-clipboard', {'frozen': 1}
Plug 'edkolev/tmuxline.vim', {'frozen': 1}

Plug 'junegunn/fzf', { 'do': { -> fzf#install() }, 'frozen': 1 }
Plug 'junegunn/fzf.vim', {'frozen': 1}
Plug 'preservim/nerdtree', {'frozen': 1}

Plug 'vim-airline/vim-airline', {'frozen': 1}
Plug 'vim-airline/vim-airline-themes', {'frozen': 1}
Plug 'ryanoasis/vim-devicons', {'frozen': 1}
Plug 'lukas-reineke/indent-blankline.nvim', {'frozen': 1}

Plug 'tpope/vim-eunuch', {'frozen': 1}
Plug 'qpkorr/vim-bufkill', {'frozen': 1}
Plug 'breuckelen/vim-resize', {'frozen': 1}
Plug 'mhinz/vim-startify', {'frozen': 1}

call plug#end()
]]


