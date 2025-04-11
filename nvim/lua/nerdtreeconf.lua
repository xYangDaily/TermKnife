-- NerdTree
vim.g.NERDTreeWinPos = 'right'
vim.g.NERDTreeMapCloseDir = vim.g.NERDTreeMapCloseDir or 'h'
vim.g.NERDTreeMapActivateNode = vim.g.NERDTreeMapActivateNode or 'l'
vim.g.NERDTreeMapJumpLastChild = '' -- delete default J
vim.g.NERDTreeMapJumpFirstChild = '' -- delete default H
vim.g.NERDTreeMapCustomOpen = ' ' -- delete default <CR>
vim.g.NERDTreeMapChangeRoot = vim.g.NERDTreeMapChangeRoot or '<CR>'

vim.api.nvim_set_keymap(
  'n', -- Normal 模式
  '<leader>j', -- 快捷键
  ':NERDTreeFocus<CR><Plug>(easymotion-w)', -- 执行的命令
  { noremap = true, silent = true } -- 映射选项
)

vim.api.nvim_set_keymap(
  'n', -- Normal 模式
  '<leader>h', -- 快捷键
  ':NERDTreeFocus<CR><Plug>(easymotion-b)', -- 执行的命令
  { noremap = true, silent = true } -- 映射选项
)

-- 自定义函数来判断当前窗口类型并执行相应操作
function NerdUpDir()
  -- 获取当前窗口的类型
  local win_type = vim.fn.win_gettype()

  if win_type == 'netrw' or vim.bo.filetype == 'nerdtree' then
    vim.api.nvim_call_function('nerdtree#ui_glue#upDir', {1})
    vim.cmd('call b:NERDTree.root.refresh()')
  else
    vim.cmd('NERDTreeFocus')
    vim.api.nvim_call_function('nerdtree#ui_glue#upDir', {1})
    vim.cmd('call b:NERDTree.root.refresh()')
    vim.api.nvim_command('wincmd p')
  end
end
vim.api.nvim_set_keymap('n', '<BS>', ':lua NerdUpDir()<CR>', { noremap = true, silent = true })


vim.keymap.set('n', '<C-p>', ':NERDTreeToggle<CR><C-W><C-P><C-W>=', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>f', ':NERDTreeFind<CR><C-W><C-P>', { noremap = true, silent = true })

vim.api.nvim_create_autocmd("DirChanged", {
  pattern = "*",
  callback = function()
    vim.cmd("NERDTreeCWD")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-W><C-P>", true, false, true), 'n', false)
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    -- 检查当前是否只有一个标签页，并且只有一个窗口
    if vim.fn.tabpagenr('$') == 1 and vim.fn.winnr('$') == 1 then
      -- 检查当前缓冲区是否为 NERDTree，并且它是否是一个标签树
      local buf = vim.api.nvim_get_current_buf()
      if vim.b.NERDTree then
        -- 退出 Vim
        vim.cmd("quit")
      end
    end
  end
})

