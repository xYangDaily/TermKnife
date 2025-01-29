" autoload/histobj.vim

" 插件的函数: 获取文件中最大值的下一个索引
function! GetNextIndexFromFile(file_path)
    " 读取文件内容
    let lines = readfile(a:file_path)

    " 初始化最大值
    let max_value = -1  " 初始为负无穷，以确保任何数字都比它大
    
    " 遍历每一行
    for line in lines
        " 获取每行的第一列（假设列是由空格分隔的）
        let first_column = matchstr(line, '^\S\+')
        
        " 尝试将第一列转换为数字
        let num = str2nr(first_column)
        
        " 如果转换成功且该数字大于当前最大值，则更新最大值
        if num != 0 || first_column == '0'
            let max_value = max([max_value, num])
        endif
    endfor
    
    " 最大值加 1，且确保最小为 1
    return max([1, max_value + 1])
endfunction

function! HistObjSort()
  let obj_exist = filereadable(g:obj_path)
  if obj_exist
    let newlines = readfile(g:obj_path)

    let reversed_lines = reverse(newlines)

    let unique_lines = []
    let seen = {}
    for line in reversed_lines
        " 提取第二列
        let col2 = split(line)[1]
        "let col2 = matchstr(line, '^\S\+\s\+\(\S\+\)')
        if !has_key(seen, col2)
            call add(unique_lines, line)
            let seen[col2] = 1
        endif
    endfor

    call sort(unique_lines, {a, b -> str2nr(matchstr(a, '^\S\+')) - str2nr(matchstr(b, '^\S\+'))})

    call writefile(unique_lines, g:obj_path)
  endif
endfunction

function! HistObjPushBackDir(dir)
    let obj_exist = filereadable(g:obj_path)
    if obj_exist
      let index = GetNextIndexFromFile(g:obj_path)
      
      let l:files = globpath(a:dir, '*', 0, 1)
      for item in l:files
          call system('echo ' . index . ' ' . item . ' >> ' . g:obj_path)
          let index += 1
      endfor
      call HistObjSort()
    endif
endfunction

function! HistObjPushBackFile()
    let var = expand('%')
    let buff_exist = filereadable(var)
    let obj_exist = filereadable(g:obj_path)

    if buff_exist && obj_exist
        let index = GetNextIndexFromFile(g:obj_path)
        " 获取文件的真实路径
        let elem = fnamemodify(var, ':p')
        " 获取索引
        call system('echo ' . index . ' ' . elem . ' >> ' . g:obj_path)
        call HistObjSort()
    endif
endfunction

augroup HistObjAction
    autocmd!
    autocmd BufNewFile,BufReadPost * call HistObjPushBackFile()
    autocmd BufWritePost * call HistObjPushBackFile()
augroup END
