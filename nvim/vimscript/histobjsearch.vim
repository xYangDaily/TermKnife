function! ReformatSelected(selected)
  let ret = a:selected

  " 删除 [BUF] 标签
  if ret =~ '^\[BUF\]'
    let ret = strpart(ret, 6)
  " 删除 + 标签
  elseif ret =~ '^+'
    let ret = strpart(ret, 2)
  endif

  return ret
endfunction

function! GetCandidate()
    let active_buffers = []
    for i in range(1, bufnr('$'))
        if buflisted(i) == 1 && &filetype != 'qf'
            call add(active_buffers, '[BUF] ' . bufname(i))
        endif
    endfor

    let obj_exist = filereadable(g:obj_path)
    if obj_exist
        let local_obj_path = g:obj_path
    else
        let local_obj_path = ''
    endif

    let candi_files = []
    if local_obj_path != ''
        let lines = readfile(local_obj_path)
        for i in reverse(lines)
           let fields = split(i)
           if len(fields) >= 2
             call add(candi_files, fields[1])
           endif
        endfor
    endif

    let current_dir = getcwd()
    for i in range(0, len(candi_files) - 1)
        if candi_files[i] =~ '^' . current_dir
            let candi_files[i] = './' . fnamemodify(candi_files[i], ':p:.')
        endif
        let candi_files[i] = '+ ' . candi_files[i]
    endfor

    let combined = extend(active_buffers, candi_files)
    return combined
endfunction


function! HistObjOpenSink(selected)
  let formatted = ReformatSelected(a:selected)
  if empty(formatted) || !filereadable(formatted)
    return
  endif
  execute "e " . formatted
endfunction

function! HistObjSearch()
    " 配置 fzf 选项
    let args = {
    \   'source': GetCandidate(),
    \   'window': { 'width': 0.5, 'height': 0.5,'yoffset':0.5,'xoffset': 0.5, 'border': 'sharp' },
    \   'options': '--reverse --border --no-sort --nth 2..' ,
    \   'sink': function('HistObjOpenSink'),
    \ }
    " 执行 fzf
    call fzf#run(args)
endfunction
command! HistObjSearch call HistObjSearch()


function! HistObjTermOpenSink(selected)
  if g:fzf_whole_routine == 1
    let formatted = ReformatSelected(a:selected)
    let result = ":" . g:histobj_fst_part . formatted . g:histobj_thr_part 
    call feedkeys(result, 'n')
    
    let pos = len(g:histobj_fst_part) + len(formatted) + 1
    let repos = "\<c-r>=setcmdpos(" . pos . ")[1]\<cr>"
    call feedkeys(repos, 'l')
  else
    let result = ":" . g:histobj_cmdline
    call feedkeys(result, 'n')
  endif
endfunction

function! HistObjSearchTerm()
  let cmdline = getcmdline()
  let cursor_pos = getcmdpos()
  let left_of_cursor = strpart(cmdline, 0, cursor_pos - 1)
  let right_of_cursor = strpart(cmdline, cursor_pos - 1)

  let last_space = strridx(left_of_cursor, ' ')
  if last_space != -1
    let first_part = strpart(left_of_cursor, 0, last_space + 1)  " 获取空格前的部分
    let second_part = strpart(left_of_cursor, last_space + 1)  " 获取空格后的部分
  else
    let first_part = ''
    let second_part = left_of_cursor
  endif

  let g:histobj_cmdline = cmdline
  let g:histobj_fst_part = first_part
  let g:histobj_sec_part = second_part
  let g:histobj_thr_part = right_of_cursor

  call feedkeys("\<C-c>", 'n')

  let options = [
  \ '--reverse',
  \ '--no-sort',
  \ '--nth', '2..',
  \ '--query', second_part
  \]
  call fzf#run({
  \ 'source': GetCandidate(),
  \ 'window': { 'width': 0.5, 'height': 0.5,'yoffset':0.5,'xoffset': 0.5, 'border': 'sharp' },
  \ 'options': options,
  \ 'sink': function('HistObjTermOpenSink'),
  \})

endfunction
command! HistObjSearchTerm call HistObjSearchTerm()

