conf_path="$HOME/.config"
mkdir -p $conf_path

if [ ! -e $conf_path/nvim ]; then
  ln -s `pwd`/nvim $conf_path/nvim
fi

if [ ! -e $conf_path/tmux ]; then
  ln -s `pwd`/tmux $conf_path/tmux
  ln -s `pwd`/tmux/tmux.conf ~/.tmux.conf
fi

chmod -R +x zsh
if [ ! -e $conf_path/zsh ]; then
  ln -s `pwd`/zsh $conf_path/zsh
  ln -s `pwd`/zsh/zshrc ~/.zshrc
fi
