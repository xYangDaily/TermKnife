local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local telescopeUtilities = require('telescope.utils')

-- 创建带有预览的选择菜单
function TagMenu()
  local word = vim.fn.expand('<cword>')  -- 获取当前光标下的单词
  local taglist = vim.fn.taglist(word)  -- 使用 taglist 获取该词的所有 taglist

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
        -- 获取原始条目数据
        local originalEntryTable = {
          value = taginfo[entry].path,
          ordinal = taginfo[entry].name,
          line = taginfo[entry].line,
          name = taginfo[entry].name,
          path = taginfo[entry].path
        }

        -- 创建自定义显示器
        local displayer = entry_display.create({
          separator = ' ',
          items = {
            { width = nil },  -- name 列的宽度
            { width = nil },  -- path 列的宽度
            { remaining = true },  -- 剩余空间自适应
          }
        })

        -- 自定义显示格式
        originalEntryTable.display = function(entry)
          return displayer({
            { entry.name },  -- 尾部显示
            { entry.path, 'TelescopeResultsComment' },  -- 使用注释样式显示路径
          })
        end

        return originalEntryTable
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
            vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, 'Search', line - 1, 0, -1)
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

