#HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=cyan"
#source /nfs/home/jiaxuyang/.config/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

#REFERENCES
#compinit
#_comp_options+=(globdots)
#source /nfs/home/jiaxuyang/.config/.fzf/shell/key-bindings.zsh
#source /nfs/home/jiaxuyang/.fzf/shell/fzf-tab/fzf-tab.plugin.zsh
#source /nfs/home/jiaxuyang/.config/zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# LF OPTS
#LF_INSERT_POSI_LOG=/nfs/home/jiaxuyang/.config/lf/.quitpath #MACRO
#LF_CD_POSI_LOG=/nfs/home/jiaxuyang/.config/lf/.cdpath #MACRO
#GrabPath() { 
#  rm -f ${LF_INSERT_POSI_LOG} ${LF_CD_POSI_LOG}
#  lf 
#  if [ -f ${LF_INSERT_POSI_LOG} ];then
#    path_to_add=$(cat ${LF_INSERT_POSI_LOG})
#    rm -f ${LF_INSERT_POSI_LOG}; 
#    LBUFFER=${LBUFFER}${path_to_add} 
#  elif [ -f ${LF_CD_POSI_LOG} ]; then
#    path_to_cd=$(cat ${LF_CD_POSI_LOG})
#    cd $path_to_cd
#    zle reset-prompt
#  fi
#  rm -f ${LF_INSERT_POSI_LOG} ${LF_CD_POSI_LOG}
#} 
#zle -N GrabPath 
#bindkey '^o' GrabPath 


#========================= QUICK CUT IN  =========================#
quick_cut_in_workdir() {
  [ "${LBUFFER}" = "" ] || [ "${LBUFFER[-1]}" = " " ] && return
  
  local query newlbuffer newrbuffer
  local lbuffer_array=(`echo ${LBUFFER}`)
  query=${lbuffer_array[-1]}
  
  local lbuffer_length=`echo -n ${LBUFFER} | wc -m`
  local query_length=`echo -n ${query} | wc -m`
  local newlbuffersize=$(($lbuffer_length - $query_length))
  newlbuffer=${LBUFFER[0,$newlbuffersize]}
  
  [ "${query[1]}" = "~" ] && query=${HOME}/${query[2,${#query}]}
  [ ! -e $query ] && return
  
  name=$(basename $(realpath -es ${query}))
  workdir=$(dirname $(realpath -es ${query}))
  cur_workdir=$(dirname .)
  [ "$workdir" = "$cur_workdir" ] && return
  
  cd $workdir
  LBUFFER="${newlbuffer}./${name}"
  
  local ret=$?
  zle reset-prompt
  return $ret
}

zle -N  quick_cut_in_workdir
bindkey '^o' quick_cut_in_workdir

