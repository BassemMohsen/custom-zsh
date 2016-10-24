#!/bin/sh

CUSTOM_ALIASES=$HOME/.oh-my-zsh/custom/gordan.zsh
CUSTOM_SCREENRC=$HOME/.screenrc

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" &
wait

[ ! -d $HOME/.oh-my-zsh ] && return 

[ ! -f $CUSTOM_ALIASES ] && ln -s $PWD/custom/gordan.zsh $CUSTOM_ALIASES
[ ! -f $CUSTOM_SCREENRC ] && ln -s $PWD/dotfiles/.screenrc $CUSTOM_SCREENRC

chsh -s $(which zsh)
