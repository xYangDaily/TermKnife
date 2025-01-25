#!/usr/bin/env zsh
if [[ ! "$PATH" = */nfs/user/jiaxuyang/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/nfs/user/jiaxuyang/.fzf/bin"
fi

__fzfcmd() {
  echo "fzf"
}
#function zsh_add_history_with_abname_stored() {
#  emulate -L zsh
#  COMMAND_STR=${1%%$'\n'}
#  echo "$PWD; $COMMAND_STR;" >> ~/.zsh_enhanced_history
#  print -Sr ${COMMAND_STR}  #write into stack
#  #fc -p                    #write into HISTFILE
#}

function zsh_ori_pos_stored() {
  emulate -L zsh
  COMMAND_STR=${1%%$'\n'}
  echo $PWD > $HIST_POS_LOG
  print -Sr ${COMMAND_STR}  #write into stack
  #fc -p                    #write into HISTFILE
}

autoload -U add-zsh-hook
add-zsh-hook -Uz zshaddhistory zsh_ori_pos_stored

function edit_abname_history(){
  abname=$1
  search_result=( `grep -n ":${abname}$" $HIST_OBJ_LOG` )
  ret=$?
  
  num=`echo ${search_result[1]} | cut -d':' -f1`
  state=`echo ${search_result[1]} | cut -d':' -f2`
    
  if [ "$state" = "n" ]; then
    del_opts=" -i ${num}d "
    sed `echo $del_opts` $HIST_OBJ_LOG
    echo n:${abname} >> $HIST_OBJ_LOG
  else
    if [ "$state" = "l" ]; then
      del_opts=" -i ${num}d "
      sed `echo $del_opts` $HIST_OBJ_LOG
    fi
      
    subdirs=(`find -L $abname -maxdepth 1`)
    if [ ${#subdirs[@]} -gt 100 ]; then return;fi
    for subdir in ${subdirs};do
      [ "${abname}" = "${subdir}" ] && continue
      sub_result=( `grep -n ":${subdir}$" $HIST_OBJ_LOG` )
      sub_ret=$?
      if [ ! $sub_ret -eq 0 ];then 
        echo l:${subdir} >> $HIST_OBJ_LOG
      elif [ ${#sub_result[@]} -eq 1 ]; then
        num=`echo ${sub_result[1]} | cut -d':' -f1`
        del_opts=" -i ${num}d "
        sed `echo $del_opts` $HIST_OBJ_LOG
        echo ${sub_result[1]} | cut -d':' -f2- >> $HIST_OBJ_LOG
      fi
    done
    echo n:${abname} >> $HIST_OBJ_LOG
  fi
  
}

function zsh_add_history_with_abname_stored() {
  lastarray=(`history | tail -n 1`)
  historycontent=(${lastarray[2,-1]})
  for part in ${historycontent};do
    local obj_path=
    if [ "${part[1]}" = "/" ];then
      obj_path=${part}
    else
      real_pwd=`cat ${HIST_POS_LOG}`
      [ "$real_pwd" = "" ] && real_pwd=`pwd`
      obj_path=${real_pwd}/${part}
    fi
    
    if [ -f $obj_path ] || [ -d $obj_path ];then 
      obj_path=`realpath $obj_path`
    else 
      continue
    fi
    
    [ ! -e $obj_path ] && continue
    $(edit_abname_history $obj_path)

  done
}

add-zsh-hook -Uz precmd zsh_add_history_with_abname_stored

HIST_CORE=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.core #MACRO
HIST_CORE_N=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.core.n #MACRO
HIST_CORE_L=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.core.l #MACRO
HIST_OTHER=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.other #MACRO
HIST_CUR_LOG=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.cur #MACRO
HIST_NLCUR_LOG=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.nrcur #MACRO
HIST_SOBJ_LOG=/nfs/user/jiaxuyang/.config/zsh/zsh-hist-obj/.sobj #MACRO

function __howsel {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  prefix=`pwd`
  find -L $prefix -maxdepth 1 | sort > $HIST_CUR_LOG
  cat $HIST_CUR_LOG | awk '{print "n:" $0; print "l:" $0}' > $HIST_NLCUR_LOG
  grep -Fxv -f $HIST_NLCUR_LOG $HIST_OBJ_LOG > $HIST_SOBJ_LOG
  nodes=(`grep -n "n:" $HIST_SOBJ_LOG`)
  cut_line=`echo ${nodes[-3]} | cut -d ':' -f1`
  other_opts="-n $((cut_line-1))"
  cat $HIST_SOBJ_LOG | head `echo $other_opts` > $HIST_OTHER
  core_opts="-n +${cut_line}"
  cat $HIST_SOBJ_LOG | tail `echo $core_opts` > $HIST_CORE
  
  grep "n:" $HIST_CORE > $HIST_CORE_N
  grep "l:" $HIST_CORE > $HIST_CORE_L
  
  selected=( $(tac $HIST_CORE_N $HIST_CUR_LOG $HIST_CORE_L $HIST_OTHER | \
    while read line;do 
      line=`echo ${line} | cut -d':' -f2` 
      local rele_line=""
      if [[ "$line" = "$prefix/"* ]];then
        prefix_slash=${prefix}/
        rele_line=`echo ${line#${prefix_slash}}`
      else 
        rele_line=`echo ${line#${prefix}}`
      fi
      
      if [ ! -z $rele_line ] && echo $rele_line
        
    done |\
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $1  +m" $(__fzfcmd)) )
  local ret=$?
  echo $selected 
  return $ret
}

history_object_widget() {
  local query_prefix freshlbuffer
  if [ "${LBUFFER[-1]}" = " " ]; then 
    query_opts=""
    LBUFFER="${LBUFFER}$(__howsel $query_opts)"
  else
    local lbuffer_array=(`echo ${LBUFFER}`)
    query_prefix=${lbuffer_array[-1]}
    query_opts="--query=${query_prefix}"
    
    local lbuffer_length=`echo -n ${LBUFFER} | wc -m`
    local query_length=`echo -n ${query_prefix} | wc -m`
    local newlbuffersize=$(($lbuffer_length - $query_length))
    freshlbuffer=${LBUFFER[0,$newlbuffersize]}
    
    local right
    search_result=$(__howsel $query_opts)
    local ret=$?
    if [ $ret -eq 0 ] || [ $ret -eq 141 ] ;then
      right=$search_result
    else
      right=$query_prefix
    fi
    #
    LBUFFER="${freshlbuffer}${right}"
  fi
  
  
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N   history_object_widget
