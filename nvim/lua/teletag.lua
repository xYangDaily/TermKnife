local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')


-- 创建带有预览的选择菜单
function TagMenu()
  local word = vim.fn.expand('<cword>')  -- 获取当前光标下的单词
  local taglist = vim.fn.taglist(word)  -- 使用 taglist 获取该词的所有 taglist

  -- 如果没有找到 taglist，返回空表
  if not taglist or #taglist == 0 then
    print("no relavant tags")
    return 
  end

  local taginfo = {}
  for i, entry in ipairs(taglist) do
    taginfo[i] = {name = entry.name, path = entry.filename, line = entry.line}
  end

  pickers.new({
    finder = finders.new_table {
      results = vim.tbl_keys(taginfo),
      entry_maker = function(entry)
        return {
          value = taginfo[entry].path,
          display = string.format("%-45s | %s", taginfo[entry].name, taginfo[entry].path),
          ordinal = taginfo[entry].name,
          line = taginfo[entry].line,
          name = taginfo[entry].name,
          path = taginfo[entry].path
        }
      end,
    },
    
    sorter = conf.generic_sorter(),
    
    previewer = previewers.new_buffer_previewer({
      title = "Match Preview",
      define_preview = function(self, entry, status)
        line = tonumber(entry.line)
        path = entry.path

        conf.buffer_previewer_maker(entry.path, self.state.bufnr, {
          bufname = self.state.bufname,
          winid = self.state.winid,
          callback = function(bufnr)
            pcall(vim.api.nvim_win_set_cursor, self.state.winid, { line, 0 })
            vim.api.nvim_buf_call(self.state.bufnr, function() vim.cmd "norm! zz" end)
          end
      })
      end,
    }),

    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local selection = action_state.get_selected_entry()
        local path = selection.path
        local line = tonumber(selection.line)
        actions.close(prompt_bufnr)

        vim.cmd('edit ' .. path)
        vim.api.nvim_win_set_cursor(0, {line, 0})
        vim.cmd('norm! zz')
      end)
      return true
    end,
  }):find()
end

-- 绑定快捷键触发弹出菜单
vim.api.nvim_set_keymap('n', '<c-t>', ':lua TagMenu()<CR>', { noremap = true, silent = true })

