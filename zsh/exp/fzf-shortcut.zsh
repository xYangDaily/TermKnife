#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
if [[ ! "$PATH" == */nfs/user/jiaxuyang/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/nfs/user/jiaxuyang/.fzf/bin"
fi

# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'

{

[[ -o interactive ]] || return 0

 #CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}
fzf-file-widget() {
  
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}

#EXCLUDE_FZF_ABSOLUTE_PATHS="/nfs/user/jiaxuyang/usr /nfs/user/jiaxuyang/workspace/miniconda3"
#__fsel() {
#  local exclude_paths_array=(`echo $EXCLUDE_FZF_ABSOLUTE_PATHS`)
#  local find_exclude_opts=""
#  for exlude_path in ${exclude_paths_array[@]};do find_exclude_opts="-not -path \"${exlude_path}/*\" "${find_exclude_opts};done
#  
#  local lbuffer_array=(`echo ${LBUFFER}`)
#  local query_prefix=${lbuffer_array[-1]}
#  
#  local query_opts=""
#  local cur_path=`pwd`
#  
#  cut_add=2
#  if [ -d ${cur_path}/${query_prefix} ] || [ -f ${cur_path}/${query_prefix} ]; then 
#    search_path=${cur_path}/${query_prefix}
#    cut_add=$(($cut_add - 1)) 
#  else
#    search_path=${cur_path}
#    query_opts="--query=${query_prefix}"
#  fi
#  
#  local cut_posi=`echo -n ${search_path} | wc -m`
#  local cut_opts="| cut -b$(($cut_posi + $cut_add))-"
#  
#  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L ${search_path}  -maxdepth 1 `echo ${find_exclude_opts}` 2> /dev/null `echo ${cut_opts}`"}"
#  setopt localoptions pipefail no_aliases 2> /dev/null
#  local item
#  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS `echo ${query_opts}`" $(__fzfcmd) -m "$@" | while read item; do
#    echo -n "${(q)item}"
#  done
#  local ret=$?
#  echo
#  return $ret
#}
#
#fzf-file-widget() {
#  local lbuffer_array=(`echo ${LBUFFER}`)
#  local query_prefix=${lbuffer_array[-1]}
#  
#  local lbuffer_length=`echo -n ${LBUFFER} | wc -m`
#  local query_length=`echo -n ${query_prefix} | wc -m`
#  local newlbuffersize=$(($lbuffer_length - $query_length))
#  local newlbuffer=${LBUFFER[0,$newlbuffersize]}
#  
#  LBUFFER="${newlbuffer}$(__fsel)"
#  local ret=$?
#  zle reset-prompt
#  return $ret
#}
__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

zle     -N   fzf-file-widget
bindkey '^n' fzf-file-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="cd ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
#fzf-history-widget() {
#  local selected num
#  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
#  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
#    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
#  local ret=$?
#  echo $selected > tmp.txt
#  #if [ -n "$selected" ]; then
#  #  num=$selected[1]
#  #  if [ -n "$num" ]; then
#  #    zle vi-fetch-history -n $num
#  #  fi
#  #fi
#  #zle reset-prompt
#  return $ret
#}

fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  echo $selected > tmp.txt
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^P' fzf-history-widget

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
