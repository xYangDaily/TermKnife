#!/usr/bin/env zsh
if [[ ! "$PATH" = *"$BINADIR"* ]]; then
  export PATH="${PATH:+${PATH}:}${BINADIR}"
fi

[[ ! -e ${HIST_LOG_DIR} ]] && mkdir -p ${HIST_LOG_DIR}
touch ${HIST_POS_LOG} ${HIST_CMD_LOG} ${HIST_OBJ_LOG} ${HIST_TMP_LOG}

__fzfcmd() {
  echo "fzf"
}

function doc_pos_and_cmd() {
  emulate -L zsh
  COMMAND_STR=${1%%$'\n'}
  if [ ! -e ${HIST_POS_LOG} ] || [ ! -e ${HIST_CMD_LOG} ];then
    return 
  fi
  echo $PWD > $HIST_POS_LOG
  echo $COMMAND_STR > ${HIST_CMD_LOG}
}
autoload -U add-zsh-hook
add-zsh-hook -Uz zshaddhistory doc_pos_and_cmd

function attach_elem_after_history_object(){
  var=$1
  # zsh has some problems while checking file existence when there is ~ as start
  [ -z $var ] && return
  [ ! -e $var ] && return

  elem=`realpath -s $var`

  index=`tail -1 $HIST_OBJ_LOG | awk 'END{if (NF==0) print 0; else print $1 + 1}'`
  sub_objs=(`find -L $elem -maxdepth 1`)

  if [ ! ${#sub_objs[@]} -gt ${HIST_ADD_SIZE} ]; then 
    [ ${#sub_objs[@]} -gt 1 ] && echo ${sub_objs[2,${#sub_objs[@]}]} | tr ' ' '\n' | awk -v start=$index '{print NR+start " " $1}' >> $HIST_OBJ_LOG
  fi

  index=`tail -1 $HIST_OBJ_LOG | awk 'END{if (NF==0) print 0; else print $1 + 1}'`
  echo $index $elem >> $HIST_OBJ_LOG
}

function attach_parts_after_history_object() {
  if [ ! -e $HIST_CMD_LOG ] || [ ! -e $HIST_POS_LOG ] || [ ! -e $HIST_OBJ_LOG ];then
    return
  fi

  # not use history command because even if cmd is null (Press CTRL-C), 
  # history will also be called.
  lastarray=(`tail -n 1 ${HIST_CMD_LOG}`)
  :> ${HIST_CMD_LOG}

  if [ ${#lastarray[@]} -eq 0 ]; then
    return 
  fi

  historycontent=(${lastarray[2,-1]})
  for part in ${historycontent};do
    obj_path=
    if [ "${part[1]}" = "/" ] ; then
      obj_path=${part}
    elif [ "${part[1]}" = "~" ]; then
      obj_path=$HOME/${part[2,${#part}]}
    else
      real_pwd=`cat ${HIST_POS_LOG}`
      [ "$real_pwd" = "" ] && real_pwd=`pwd`
      obj_path=${real_pwd}/${part}
    fi

    $(attach_elem_after_history_object $obj_path)
  done
}
add-zsh-hook -Uz precmd attach_parts_after_history_object

sort_history_object() {
  tac $HIST_OBJ_LOG | awk '!x[$2]++'  | sort -n -k1,1 -o $HIST_OBJ_LOG

  #cat $HIST_OBJ_LOG | sort -n -r -k2,2 -k1,1 | sort -u -k2,2 | sort -n -k1,1 -o $HIST_OBJ_LOG
  #tac $HIST_OBJ_LOG | sort -u -k2,2 | sort -n -k1,1 -o $HIST_OBJ_LOG
}
add-zsh-hook -Uz periodic sort_history_object


function __howsel {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

  #prefix=`pwd`
  #$(attach_elem_after_history_object $prefix)

  #selected=( $(cat $HIST_OBJ_LOG | sort -n -r -k2,2 -k1,1 | sort -u -k2,2 | sort -n -k1,1 | awk '{print $2}' | \
  #selected=( $(tac $HIST_OBJ_LOG | sort -u -k2,2 | sort -r -n -k1,1 | awk '{print $2}' | \

  selected=( $(tac $HIST_OBJ_LOG | awk '!x[$2]++'  | awk '{print $2}' | \
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $1  +m" $(__fzfcmd)) )

  local ret=$?
  # echo needed
  echo $selected 
  return $ret
}

search_history_object() {
  if [ ! -e $HIST_CMD_LOG ] || [ ! -e $HIST_POS_LOG ] || [ ! -e $HIST_OBJ_LOG ];then
    return
  fi
  local query newlbuffer
  if [ "${LBUFFER}" = "" ] || [ "${LBUFFER[-1]}" = " " ]; then
    query_opts=""
    LBUFFER="${LBUFFER}$(__howsel $query_opts)"
  else
    local lbuffer_array=(`echo ${LBUFFER}`)
    query=${lbuffer_array[-1]}
    query_opts="--query=${query}"

    local lbuffer_length=`echo -n ${LBUFFER} | wc -m`
    local query_length=`echo -n ${query} | wc -m`
    local newlbuffersize=$(($lbuffer_length - $query_length))
    newlbuffer=${LBUFFER[0,$newlbuffersize]}

    local right
    search_result=$(__howsel $query_opts)
    local ret=$?
    if [ $ret -eq 0 ] || [ $ret -eq 141 ] ;then
      right=$search_result
    else
      right=$query
    fi
    #
    LBUFFER="${newlbuffer}${right}"
  fi
  
  
  local ret=$?
  zle reset-prompt
  return $ret
}

zle -N  search_history_object

fix_history_object() {
  rm -f ${HIST_TMP_LOG} && touch ${HIST_TMP_LOG} || return
  cat $HIST_OBJ_LOG | awk '{print $2}' | while read line; do
    if [ ! -z $line ] && [ -e $line ];then 
      real_path=`realpath -s $line`
      echo $real_path >> ${HIST_TMP_LOG}
    fi
  done
  awk '{print NR " " $1}' ${HIST_TMP_LOG} >  ${HIST_OBJ_LOG}
  
  cat ${HIST_OBJ_LOG} | sort -n -r -k2,2 -k1,1 | sort -u -k2,2 | sort -n -k1,1 -o ${HIST_OBJ_LOG}
  
  cat ${HIST_OBJ_LOG} | awk '{print NR " " $2}' | sort -n -k1,1 -o ${HIST_OBJ_LOG}
  
  rm -f ${HIST_TMP_LOG} 
}
zle -N   fix_history_object
