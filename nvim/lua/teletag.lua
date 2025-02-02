local telescope = require('telescope')
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values


-- 创建带有预览的选择菜单
function show_taglist_with_preview()
  local word = vim.fn.expand('<cword>')  -- 获取当前光标下的单词
  local taglist = vim.fn.taglist(word)  -- 使用 taglist 获取该词的所有 taglist
  
  -- 如果没有找到 taglist，返回空表
  if not taglist or #taglist == 0 then
    print("没有找到相关 tags_found")
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
          value = taginfo[entry].name,
          display = string.format("%-45s | %s", taginfo[entry].name, taginfo[entry].path),
          ordinal = entry,
          line = taginfo[entry].line,
          name = taginfo[entry].name,
          path = taginfo[entry].path
        }
      end,
    },
    sorter = conf.generic_sorter(),
    -- previewer = previewers.new_buffer_previewer({
    -- previewer = previewers.vim_buffer_vimgrep.new({
    -- previewer = previewers.vim_buffer_cat.new({
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry, status)
        line = entry.line
        path = entry.path

        local preview_content = {}  
        local all_lines = vim.fn.readfile(path)
        if tonumber(line) < #all_lines then
          for i = line, #all_lines do
            table.insert(preview_content, all_lines[i])
          end
        end
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_content)
        
        
      end,
    }),
  }):find()
end

-- 绑定快捷键触发弹出菜单
vim.api.nvim_set_keymap('n', '<c-t>', ':lua show_taglist_with_preview()<CR>', { noremap = true, silent = true })
