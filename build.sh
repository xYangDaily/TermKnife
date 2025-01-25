conf_path="~/.config"
mkdir -p $conf_path

if [ ! -e $conf_path/nvim ];
  ln -s nvim $conf_path/nvim
fi

if [ ! -e $conf_path/tmux ];
  ln -s tmux $conf_path/tmux
  ln -s tmux/tmux.conf ~/.tmux.conf
fi

chmod -R +x zsh
if [ ! -e $conf_path/zsh ];
  ln -s zsh $conf_path/zsh
  ln -s zsh/zshrc ~/.zshrc
fi
