-- hist_obj.lua

function reformat_selected(selected)
    if selected ~= "" then
        -- 如果以 [BUF] 开头，删除 [BUF] 标签
        if selected:match("^%[BUF%]") then
            selected = selected:sub(7)
        -- 如果以 + 开头，删除 + 标签
        elseif selected:match("^%+") then
            selected = selected:sub(3)
        end
    end
    return selected
end

function DeleteBufLabel(selected)
    vim.cmd("e " .. reformat_selected(selected))
end

function get_selected_list()
    -- 获取活动的缓冲区
    local active_buffers = {}
    for i = 1, vim.fn.bufnr("$") do
        if vim.fn.buflisted(i) == 1 and vim.bo[i].filetype ~= "qf" then
            table.insert(active_buffers, "[BUF] " .. vim.fn.bufname(i))
        end
    end

    -- 获取 obj_path 配置
    local obj_exist = vim.fn.glob(vim.g.obj_path) ~= ""
    if obj_exist then
      obj_path = vim.g.obj_path
    else
      obj_path = ""
    end

    local candi_files = {}
    if obj_path ~= "" then
        local lines = vim.fn.readfile(obj_path)
        for i = #lines, 1, -1 do
            local match = lines[i]:match("^%S+%s+(%S+)")
            if match then
                table.insert(candi_files, match)
            end
        end
    end

    -- 处理当前工作目录中的文件路径
    local current_dir = vim.fn.getcwd()
    for i, file in ipairs(candi_files) do
        if file:match("^" .. current_dir) then
            candi_files[i] = "./" .. vim.fn.fnamemodify(file, ":p:.")
        end
        candi_files[i] = "+ " .. candi_files[i]
    end

    -- 合并活动缓冲区和候选文件
    local combined = vim.list_extend(active_buffers, candi_files)
    return combined
end

-- HistObjFzf 函数
function HistObjFzf()
    -- 配置 fzf 选项
    local args = {
        source = get_selected_list(),
        down = "~40%",
        options = "--reverse --no-sort --nth 2..",
        sink = DeleteBufLabel,
    }

    -- 执行 fzf
    vim.fn["fzf#run"](args)
end

function HistObjTerm()
  local cmdline = vim.fn.getcmdline()
  local cursor_pos = vim.fn.getcmdpos()
  local left_of_cursor = cmdline:sub(1, cursor_pos - 1)
  local right_of_cursor = cmdline:sub(cursor_pos)
  local space_pos = left_of_cursor:match(".*%s()") - 1

  local first_part, second_part
  if space_pos then
    first_part = left_of_cursor:sub(1, space_pos)
    second_part = left_of_cursor:sub(space_pos + 1)
  else
    first_part = ""
    second_part = left_of_cursor
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, false, true), 'n', true)
  
  local options = {
    '--reverse',       -- 反转结果顺序
    '--no-sort',       -- 禁止排序
    '--nth', '2..',    -- 只考虑从第二列开始的内容
    '--query', second_part, -- 使用 second_part 作为默认查询
  }
  vim.fn['fzf#run']({
    source = get_selected_list(),
    down = "~40%",
    options = options,
    sink = function(selected)
      local fzf_whole_routine = vim.g.fzf_whole_routine
      if fzf_whole_routine == 1 then
        local result = ":" .. first_part .. reformat_selected(selected) .. right_of_cursor
        vim.fn.feedkeys(result, 'n')
      else
        local result = ":" .. cmdline
        vim.fn.feedkeys(result, 'n')
      end
    end,
  })
end

function get_file_line_count(file_path)
  local lines = vim.fn.readfile(file_path)

  -- 初始化最大值
  local max_value = -1  -- 初始为负无穷，以确保任何数字都比它大
  
  -- 遍历每一行
  for _, line in ipairs(lines) do
    -- 获取每行的第一列（假设列是由空格分隔的）
    local first_column = string.match(line, "^(%S+)")  -- 获取第一列
    local num = tonumber(first_column)  -- 转换为数字
  
    -- 如果转换成功且该数字大于当前最大值，则更新最大值
    if num then
      max_value = math.max(max_value, num)
    end
  end
  max_value = max_value + 1
  max_value = math.max(1, max_value)
  return max_value
end

function HistObjWrite()
    local var = vim.fn.expand('%')
    local buff_exist = vim.fn.glob(var) ~= ""
    
    local obj_exist = vim.fn.glob(vim.g.obj_path) ~= ""

    if buff_exist and obj_exist then
      -- 获取文件的真实路径
      local elem = vim.fn.fnamemodify(var, ":p")
      -- 获取索引
      local index = get_file_line_count(vim.g.obj_path)

      vim.fn.system('echo ' .. index .. ' ' .. elem .. ' >> ' .. vim.g.obj_path)
    end
end

function HistObjSort()
  -- 使用 vim.g.obj_path 获取文件路径
  local obj_exist = vim.fn.glob(vim.g.obj_path) ~= ""
  if obj_exist then
    obj_path = vim.g.obj_path
  else
    obj_path = ""
  end

  if obj_path ~= "" then
    -- 读取文件内容
    local file = io.open(obj_path, "r")
    if not file then
      print("无法打开文件: " .. hist_obj_log)
      return
    end

    -- 读取文件的所有行并存入一个表
    local lines = {}
    for line in file:lines() do
      table.insert(lines, line)
    end
    file:close()

    -- 反转行内容（类似 tac）
    local reversed_lines = {}
    for i = #lines, 1, -1 do
      table.insert(reversed_lines, lines[i])
    end

    -- 去重：通过一个临时表来实现唯一性
    local unique_lines = {}
    local seen = {}
    for _, line in ipairs(reversed_lines) do
      --local col2 = line:match("^(%S+)")  -- 提取第二列
      local col2 = line:match("^%S+%s+(%S+)")
      if not seen[col2] then
        table.insert(unique_lines, line)
        seen[col2] = true
      end
    end

    -- 排序：按第一列排序
    table.sort(unique_lines, function(a, b)
      local col1_a = tonumber(a:match("^(%S+)"))
      local col1_b = tonumber(b:match("^(%S+)"))
      return col1_a < col1_b
    end)

    -- 打开文件并重写内容
    local write_file = io.open(obj_path, "w")
    if not write_file then
      print("无法打开文件进行写入: " .. hist_obj_log)
      return
    end

    -- 将排序后的内容写回文件
    for _, line in ipairs(unique_lines) do
      write_file:write(line .. "\n")
    end
    write_file:close()
  end
end

function HistUpdate()
  HistObjWrite()
  HistObjSort()
end

-- 创建自动命令组
vim.api.nvim_exec([[
  augroup HistObjAction
    autocmd!
    autocmd BufNewFile,BufReadPost * lua HistUpdate()
    autocmd BufWritePost * lua HistUpdate()
  augroup END
]], false)

