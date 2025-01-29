-- 基础设置
vim.o.compatible = false
vim.o.fdm = "syntax"
vim.o.hidden = true
vim.o.encoding = "utf-8"
vim.cmd("syntax on")
vim.o.wildmode = "longest,list"
vim.o.wildmenu = true

local use_obj = true
vim.g.fzf_layout = { down = "~70%"}
vim.g.obj_path = vim.fn.expand("~/.cache/zsh/zsh-hist-obj/.obj")

-- 配色方案
vim.cmd("colorscheme habamax")
vim.o.cursorline = true

-- Leader 键
vim.g.mapleader = " "

-- ========== Plugins ==========
require('plugins')

-- ========== Input ==========
vim.keymap.set("i", "<CR>", "<CR>x<BS>")
vim.keymap.set("n", "o", "ox<BS>")
vim.keymap.set("n", "O", "Ox<BS>")

vim.keymap.set("i", "<C-y>", "<Left><C-o>dvT<Space>")
vim.keymap.set("n", "ci<Space>", "f<Space>i<C-y>")

-- ========== Motion In Cache ==========
vim.keymap.set("n", "U", "J")
vim.keymap.set("n", "J", "<Plug>(easymotion-w)")
vim.keymap.set("n", "L", "<Plug>(easymotion-e)")
vim.keymap.set("n", "K", "<Plug>(easymotion-ge)")
vim.keymap.set("n", "H", "<Plug>(easymotion-b)")

vim.keymap.set("v", "J", "<Plug>(easymotion-w)")
vim.keymap.set("v", "L", "<Plug>(easymotion-e)")
vim.keymap.set("v", "K", "<Plug>(easymotion-ge)")
vim.keymap.set("v", "H", "<Plug>(easymotion-b)")

vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", { noremap = true })

require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    '<C-u>', '<C-d>',
    '<C-y>', '<C-e>',
    'zt', 'zz', 'zb',
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 1.0,   -- Global duration multiplier
  easing = 'linear',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
  ignored_events = {           -- Events ignored while scrolling
      'WinScrolled', 'CursorMoved'
  },
})

-- ========== Search ==========
vim.o.incsearch = true
vim.o.hlsearch = true
vim.g.select_and_search_active = 3
vim.keymap.set("n", "<C-f>", ":Lines<CR>")

-- ========== Settings For Tab ==========
vim.keymap.set("n", "<C-s>", ":BD!<CR>")
vim.keymap.set("n", "<C-x>", ":close!<CR>")

vim.api.nvim_set_keymap('n', '(', ':bp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ')', ':bn<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>1', '<Plug>AirlineSelectTab1', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>2', '<Plug>AirlineSelectTab2', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>3', '<Plug>AirlineSelectTab3', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>4', '<Plug>AirlineSelectTab4', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>5', '<Plug>AirlineSelectTab5', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>6', '<Plug>AirlineSelectTab6', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>7', '<Plug>AirlineSelectTab7', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>8', '<Plug>AirlineSelectTab8', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>9', '<Plug>AirlineSelectTab9', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>0', '<Plug>AirlineSelectTab0', { noremap = true, silent = true })


-- ========== Settings For Windows ==========
vim.o.splitright = true
vim.o.splitbelow = true

vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")

vim.keymap.set("n", "<M-h>", ":CmdResizeLeft<CR>")
vim.keymap.set("n", "<M-j>", ":CmdResizeDown<CR>")
vim.keymap.set("n", "<M-k>", ":CmdResizeUp<CR>")
vim.keymap.set("n", "<M-l>", ":CmdResizeRight<CR>")


-- ========== Settings For Files ==========
if use_obj then
  vim.keymap.set('n', '<c-n>', function()
    vim.cmd('HistObjSearch')
  end)
  vim.keymap.set('c', '<c-n>', function()
    vim.cmd('HistObjSearchTerm')
  end)
end

require('nerdtreeconf')

-- ========== Settings For Terminal ==========
vim.api.nvim_set_keymap("c", "<C-j>", "<DOWN>", { noremap = true })
vim.api.nvim_set_keymap("c", "<C-k>", "<UP>", { noremap = true })
vim.api.nvim_set_keymap("c", "<C-a>", "<Home>", { noremap = true })
vim.api.nvim_set_keymap("c", "<M-h>", "<S-Left>", { noremap = true })
vim.api.nvim_set_keymap("c", "<M-l>", "<S-Right>", { noremap = true })

vim.api.nvim_set_keymap("n", "CD", ":cd %:p:h<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-c>", ":echo expand('%:p:h')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-g>", "<C-]>", { noremap = true, silent = true })

-- ========== Format ==========
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.autoindent = true

vim.opt.list = true  -- 启用可见字符显示
vim.opt.listchars:append("trail:•")  -- 行尾多余空格显示为圆点
require('ibl').setup({
  scope = { enabled = false },
  exclude = {
    filetypes = {
      'help',
      'startify',
      'aerial',
      'alpha',
      'dashboard',
      'packer',
      'neogitstatus',
      'NvimTree',
      'neo-tree',
      'Trouble',
    },
    buftypes = {
      'nofile',
      'terminal',
    },
  },
})

-- airline 设置
--vim.opt.showtabline = 1
vim.g.airline_theme = "violet"
vim.g.airline_left_sep = ""
vim.g.airline_left_alt_sep = "❯"
vim.g.airline_right_sep = ""
vim.g.airline_right_alt_sep = "❮"
vim.g["airline#extensions#tmuxline#enabled"] = 1
vim.g["airline#extensions#tabline#left_sep"] = " "
vim.g["airline#extensions#tabline#left_alt_sep"] = "❯"
vim.g["airline#extensions#tabline#right_sep"] = ""
vim.g["airline#extensions#tabline#right_alt_sep"] = "❮"
vim.g["airline#extensions#tabline#buf_label_first"] = 1
vim.g["airline#extensions#tabline#buffers_label"] = "+"
vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline#extensions#tabline#buffer_idx_mode"] = 1
vim.g["airline#extensions#tabline#formatter"] = "short_path"


-- ========== Startify ==========
vim.g.startify_enable_special = 0
vim.g.startify_files_number = 0

-- ========== EXP ==========
require('exp')
