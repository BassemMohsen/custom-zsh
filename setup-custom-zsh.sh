#!/bin/sh

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" &
wait

[ ! -d $HOME/.oh-my-zsh ] && return 

ln -s $PWD/custom/gordan.zsh $HOME/.oh-my-zsh/custom/gordan.zsh
ln -s $PWD/dotfiles/.screenrc $HOME/.screenrc

chsh -s $(which zsh)
